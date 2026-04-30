"""
CRAFT v4 — End-to-end runner.

Wires the seven stages together:

    prompt
        → BaselineGenerator     (Stage 0: GPT-5.2 direct SCAD)
        → RenderCheck.baseline   (Stage 1+2: render + sanity)
        → KBReference.lookup     (Stage 3: optional informational hint)
        → GapAssessor.assess     (Stage 4: VLM gap report on baseline)
        → SCADPatcher.patch      (Stage 5: single targeted patch from baseline)
        → RenderCheck.patched    (Stage 6: re-render patched output)
        → GapAssessor.assess     (Stage 4b: gap report on patched output)
        → RegressionGate.decide  (Stage 7: keep patched only if non-regress)
        → V4Result with chosen SCAD/STL/views + full audit trail

Outputs are written to ``out_dir/<prompt_id>/``:
    baseline.scad, baseline.stl, baseline_views/*.png
    patched.scad,  patched.stl,  patched_views/*.png   (if a patch ran)
    final.scad     ── symlink/copy of whichever the gate chose
    final.stl
    final_views/   ── view directory of the chosen render set
    audit.json     ── machine-readable timeline of every stage
"""

from __future__ import annotations

import json
import os
import shutil
import sys
import time
from dataclasses import dataclass, asdict, field
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

from openai import OpenAI

# Pipeline-root import shim.
_PIPELINE_ROOT = Path(__file__).resolve().parent.parent
if str(_PIPELINE_ROOT) not in sys.path:
    sys.path.insert(0, str(_PIPELINE_ROOT))

from core.llm_client import create_unified_client  # noqa: E402

from .baseline_generator import BaselineGenerator, BaselineOutput
from .gap_assessor import GapAssessor, GapReport
from .kb_reference import KBHint, KBReference
from .patcher import PatchOutput, SCADPatcher
from .regression_gate import GateDecision, GateInputs, RegressionGate
from .render_check import RenderArtifacts, RenderCheck


@dataclass
class V4Config:
    """Tunables for the v4 runner.

    ``baseline_models`` is the list of Stage-0 generators that will run in
    parallel. The first entry is the "preferred" baseline — used as the
    tie-breaker by the regression gate. Default is gpt-5.2 + gpt-4o
    because empirically gpt-4o wins on simple primitive geometry while
    gpt-5.2 wins on complex assemblies; an oracle over the two beats
    either alone.

    For backward compatibility, ``baseline_model`` (singular) still works:
    if set, it overrides ``baseline_models`` with a single-element list.
    """
    baseline_models: List[str] = field(default_factory=lambda: ["gpt-5.2", "gpt-4o"])
    baseline_model: Optional[str] = None    # legacy single-model field

    # Pre-generated SCAD baselines (e.g. craft-v1 outputs from
    # run_craft_v1_on_v2.py). Keys are arbitrary names used in audit logs;
    # values are directories that contain ``scad/<prompt_id>.scad`` files.
    # The runner reads the SCAD, renders + sanity-checks + assesses it
    # exactly like a model-generated baseline, and the gate considers it
    # alongside the LLM candidates.
    external_baselines: Dict[str, str] = field(default_factory=dict)

    assessor_model: str = "gpt-5.2"
    patcher_model: str = "gpt-5.2"
    use_kb: bool = True
    kb_min_score: float = 0.85
    enable_patch: bool = True

    # Gate margin: a patch must add at least this many passing criteria
    # over the chosen baseline to be kept. Default 2 is empirically derived
    # from the canonical 30 v2 run (margin-1 patches were a coin flip).
    min_patch_gain: int = 2

    sketch_path: Optional[str] = None
    render_imgsize: tuple = (512, 512)
    render_distance: float = 200.0
    render_timeout: int = 90
    stl_timeout: int = 240

    def __post_init__(self):
        # Legacy single-model field overrides the list.
        if self.baseline_model:
            self.baseline_models = [self.baseline_model]


@dataclass
class V4Result:
    """Full audit trail of one v4 run."""
    prompt_id: str
    prompt_text: str
    out_dir: str

    # Final selection (whichever the gate kept)
    chosen: str = "baseline"
    final_scad_path: str = ""
    final_stl_path: str = ""
    final_views_dir: str = ""

    # Per-baseline summaries (one entry per Stage-0 model run)
    baselines: List[Dict[str, Any]] = field(default_factory=list)

    # Selected best baseline (used as the patcher's input)
    chosen_baseline_model: str = ""
    chosen_baseline_reason: str = ""

    # Headline baseline metrics (==chosen baseline; kept for downstream
    # scripts that consume the flat fields).
    baseline_code: str = ""
    baseline_render_ok: bool = False
    baseline_stl_ok: bool = False
    baseline_failed_views: int = 0
    baseline_criteria_pass: int = 0
    baseline_criteria_total: int = 0

    patch_attempted: bool = False
    patch_is_noop: bool = False
    patched_code: str = ""
    patched_render_ok: bool = False
    patched_stl_ok: bool = False
    patched_failed_views: int = 0
    patched_criteria_pass: int = 0
    patched_criteria_total: int = 0

    # KB
    kb_fired: bool = False
    kb_top_score: float = 0.0
    kb_components: list = field(default_factory=list)

    # Gate
    gate_reason: str = ""

    # Timing
    elapsed_s: float = 0.0

    # Errors (any stage)
    errors: list = field(default_factory=list)

    def to_dict(self) -> Dict[str, Any]:
        d = asdict(self)
        return d


class V4Runner:
    """End-to-end orchestrator for CRAFT v4."""

    def __init__(
        self,
        config: Optional[V4Config] = None,
        openai_client: Optional[OpenAI] = None,
    ):
        self.config = config or V4Config()
        self.openai_client = openai_client or OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
        self.unified_client = create_unified_client(openai_client=self.openai_client)

        # One generator per baseline model.
        self.baseline_gens: Dict[str, BaselineGenerator] = {
            model: BaselineGenerator(client=self.openai_client, model=model)
            for model in self.config.baseline_models
        }
        self.kb = (
            KBReference(min_score=self.config.kb_min_score) if self.config.use_kb else None
        )
        self.assessor = GapAssessor(
            client=self.unified_client,
            model=self.config.assessor_model,
        )
        self.patcher = SCADPatcher(
            client=self.openai_client,
            model=self.config.patcher_model,
        )
        self.gate = RegressionGate(min_patch_gain=self.config.min_patch_gain)
        self.render = RenderCheck(
            imgsize=self.config.render_imgsize,
            render_distance=self.config.render_distance,
            render_timeout=self.config.render_timeout,
            stl_timeout=self.config.stl_timeout,
        )

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    def run(self, prompt_id: str, prompt_text: str, out_dir: str) -> V4Result:
        t0 = time.time()
        os.makedirs(out_dir, exist_ok=True)
        result = V4Result(prompt_id=prompt_id, prompt_text=prompt_text, out_dir=out_dir)

        # ----- Stage 3: KB reference (informational only) -----
        kb_hint_text: Optional[str] = None
        if self.kb is not None:
            try:
                hint: KBHint = self.kb.lookup(prompt_text)
                result.kb_fired = hint.fired
                result.kb_top_score = hint.top_score
                result.kb_components = list(hint.matched_components)
                if hint.fired and hint.text:
                    kb_hint_text = hint.text
            except Exception as e:
                result.errors.append(f"kb lookup failed: {e}")

        # ----- Stage 0/1/2/4: per-baseline generate + render + assess -----
        # For each baseline model: generate SCAD, render, sanity-check, run
        # the gap assessor. We collect everything that survives sanity into a
        # candidate list and let the regression gate pick the best.
        baseline_records: List[Dict[str, Any]] = []
        baseline_arts: Dict[str, RenderArtifacts] = {}
        baseline_reports: Dict[str, GapReport] = {}
        baseline_codes: Dict[str, str] = {}
        baseline_scad_paths: Dict[str, str] = {}

        for model in self.config.baseline_models:
            label = self._safe_model_label(model)
            scad_path = os.path.join(out_dir, f"baseline_{label}.scad")

            gen_out: BaselineOutput = self.baseline_gens[model].generate(
                prompt_text, kb_hint=kb_hint_text
            )
            if not gen_out.ok:
                result.errors.append(f"baseline {model} generation failed: {gen_out.error}")
                baseline_records.append({
                    "model": model,
                    "ok": False,
                    "error": gen_out.error,
                })
                continue

            with open(scad_path, "w") as f:
                f.write(gen_out.code)
            baseline_codes[model] = gen_out.code
            baseline_scad_paths[model] = scad_path

            art = self.render.render_and_check(
                scad_path=scad_path, out_dir=out_dir, prefix=f"baseline_{label}",
            )
            baseline_arts[model] = art

            report = (
                self._safe_assess(prompt_text, art.view_paths, kb_hint_text)
                if art.view_paths
                else GapReport(error=f"no views for {model}")
            )
            baseline_reports[model] = report

            baseline_records.append({
                "model": model,
                "ok": True,
                "render_success": bool(art.sanity and art.sanity.render_success),
                "stl_success": bool(art.sanity and art.sanity.stl_success),
                "num_failed_views": art.sanity.num_failed_views if art.sanity else 999,
                "criteria_pass": report.num_pass,
                "criteria_total": report.num_total,
                "fitness_proxy": report.fitness_proxy,
                "report_error": report.error,
            })

        # ----- Stage 0b: external pre-generated baselines (e.g. craft-v1) -----
        # Read SCAD from disk for each external baseline, render + assess
        # the same way as model-generated baselines.
        for ext_name, ext_dir in self.config.external_baselines.items():
            ext_dir_p = Path(ext_dir)
            # Accept either flat layout (<dir>/<id>.scad) or
            # standard layout (<dir>/scad/<id>.scad).
            cand_paths = [
                ext_dir_p / "scad" / f"{prompt_id}.scad",
                ext_dir_p / f"{prompt_id}.scad",
            ]
            src_scad = next((c for c in cand_paths if c.exists()), None)
            if src_scad is None:
                baseline_records.append({
                    "model": ext_name,
                    "ok": False,
                    "error": f"external SCAD not found in {ext_dir}",
                })
                continue

            label = self._safe_model_label(ext_name)
            scad_path = os.path.join(out_dir, f"baseline_{label}.scad")
            try:
                ext_code = src_scad.read_text()
            except Exception as e:
                baseline_records.append({
                    "model": ext_name, "ok": False,
                    "error": f"could not read {src_scad}: {e}",
                })
                continue
            with open(scad_path, "w") as f:
                f.write(ext_code)
            baseline_codes[ext_name] = ext_code
            baseline_scad_paths[ext_name] = scad_path

            art = self.render.render_and_check(
                scad_path=scad_path, out_dir=out_dir, prefix=f"baseline_{label}",
            )
            baseline_arts[ext_name] = art

            report = (
                self._safe_assess(prompt_text, art.view_paths, kb_hint_text)
                if art.view_paths
                else GapReport(error=f"no views for {ext_name}")
            )
            baseline_reports[ext_name] = report

            baseline_records.append({
                "model": ext_name,
                "ok": True,
                "external": True,
                "render_success": bool(art.sanity and art.sanity.render_success),
                "stl_success": bool(art.sanity and art.sanity.stl_success),
                "num_failed_views": art.sanity.num_failed_views if art.sanity else 999,
                "criteria_pass": report.num_pass,
                "criteria_total": report.num_total,
                "fitness_proxy": report.fitness_proxy,
                "report_error": report.error,
            })

        result.baselines = baseline_records

        # If every baseline call failed outright, bail.
        if not baseline_codes:
            self._write_audit(result)
            result.elapsed_s = time.time() - t0
            return result

        # ----- Pick the best baseline among all candidates -----
        # Order LLM models first (so they tie-break ahead of externals by
        # default), then external baselines.
        candidate_order: List[str] = (
            list(self.config.baseline_models)
            + list(self.config.external_baselines.keys())
        )
        baseline_inputs_list: List[GateInputs] = []
        for cand_name in candidate_order:
            if cand_name not in baseline_codes:
                continue
            art = baseline_arts[cand_name]
            report = baseline_reports[cand_name]
            baseline_inputs_list.append(GateInputs(
                name=f"baseline_{self._safe_model_label(cand_name)}",
                scad_code=baseline_codes[cand_name],
                scad_path=baseline_scad_paths[cand_name],
                stl_path=art.stl_path,
                view_paths=art.view_paths,
                criteria_pass=report.num_pass,
                criteria_total=report.num_total,
                num_failed_views=(
                    art.sanity.num_failed_views if art.sanity else 999
                ),
                stl_success=bool(art.sanity and art.sanity.stl_success),
            ))

        chosen_baseline_inputs, baseline_pick_reason = self.gate.select_best_baseline(
            baseline_inputs_list,
        )
        if chosen_baseline_inputs is None:
            result.errors.append("no usable baseline produced")
            self._write_audit(result)
            result.elapsed_s = time.time() - t0
            return result

        # Reverse-map the chosen GateInputs back to its source name.
        # Could be a model id (gpt-5.2) or an external baseline name (craft-v1).
        all_candidate_names = (
            list(self.config.baseline_models)
            + list(self.config.external_baselines.keys())
        )
        chosen_model = next(
            n for n in all_candidate_names
            if n in baseline_codes
            and self._safe_model_label(n) ==
                chosen_baseline_inputs.name.removeprefix("baseline_")
        )
        baseline_art = baseline_arts[chosen_model]
        baseline_report = baseline_reports[chosen_model]
        baseline_scad_path = baseline_scad_paths[chosen_model]
        baseline_code = baseline_codes[chosen_model]

        result.chosen_baseline_model = chosen_model
        result.chosen_baseline_reason = baseline_pick_reason
        result.baseline_code = baseline_code
        result.baseline_render_ok = bool(baseline_art.sanity and baseline_art.sanity.render_success)
        result.baseline_stl_ok = bool(baseline_art.sanity and baseline_art.sanity.stl_success)
        result.baseline_failed_views = (
            baseline_art.sanity.num_failed_views if baseline_art.sanity else 999
        )
        result.baseline_criteria_pass = baseline_report.num_pass
        result.baseline_criteria_total = baseline_report.num_total
        if baseline_report.error:
            result.errors.append(f"baseline gap-assess: {baseline_report.error}")

        # Default final = chosen baseline.
        result.chosen = "baseline"
        result.final_scad_path = baseline_scad_path
        result.final_stl_path = baseline_art.stl_path
        result.final_views_dir = self._dir_of(baseline_art.view_paths)

        # ----- Stage 5: Patch decision -----
        # We always patch FROM the chosen baseline, never from a previous patch.
        patched_art: Optional[RenderArtifacts] = None
        patched_report: Optional[GapReport] = None
        patched_scad_path: Optional[str] = None

        if self.config.enable_patch and baseline_report.needs_patch():
            result.patch_attempted = True
            patch_out: PatchOutput = self.patcher.patch(
                prompt=prompt_text,
                baseline_scad=baseline_code,
                gap_report=baseline_report,
                kb_hint=kb_hint_text,
            )
            if patch_out.error:
                result.errors.append(f"patcher: {patch_out.error}")
            elif patch_out.is_noop:
                result.patch_is_noop = True
            else:
                patched_scad_path = os.path.join(out_dir, "patched.scad")
                with open(patched_scad_path, "w") as f:
                    f.write(patch_out.code)
                result.patched_code = patch_out.code

                # ----- Stage 6: Render patched -----
                patched_art = self.render.render_and_check(
                    scad_path=patched_scad_path,
                    out_dir=out_dir,
                    prefix="patched",
                )
                result.patched_render_ok = bool(
                    patched_art.sanity and patched_art.sanity.render_success
                )
                result.patched_stl_ok = bool(
                    patched_art.sanity and patched_art.sanity.stl_success
                )
                result.patched_failed_views = (
                    patched_art.sanity.num_failed_views if patched_art.sanity else 999
                )

                # ----- Stage 4b: Gap assessment on patched -----
                patched_report = (
                    self._safe_assess(prompt_text, patched_art.view_paths, kb_hint_text)
                    if patched_art.view_paths
                    else GapReport(error="no patched views")
                )
                result.patched_criteria_pass = patched_report.num_pass
                result.patched_criteria_total = patched_report.num_total
                if patched_report.error:
                    result.errors.append(f"patched gap-assess: {patched_report.error}")

        # ----- Stage 7: Non-regression gate -----
        baseline_inputs = GateInputs(
            name=f"baseline_{self._safe_model_label(chosen_model)}",
            scad_code=baseline_code,
            scad_path=baseline_scad_path,
            stl_path=baseline_art.stl_path,
            view_paths=baseline_art.view_paths,
            criteria_pass=baseline_report.num_pass,
            criteria_total=baseline_report.num_total,
            num_failed_views=result.baseline_failed_views,
            stl_success=result.baseline_stl_ok,
        )
        if patched_art is not None and patched_report is not None and patched_scad_path:
            patched_inputs = GateInputs(
                name="patched",
                scad_code=result.patched_code,
                scad_path=patched_scad_path,
                stl_path=patched_art.stl_path,
                view_paths=patched_art.view_paths,
                criteria_pass=patched_report.num_pass,
                criteria_total=patched_report.num_total,
                num_failed_views=result.patched_failed_views,
                stl_success=result.patched_stl_ok,
            )
        else:
            patched_inputs = None

        decision: GateDecision = self.gate.decide(baseline_inputs, patched_inputs)
        result.gate_reason = decision.reason

        if decision.kept_patch and patched_art is not None and patched_scad_path:
            result.chosen = "patched"
            result.final_scad_path = patched_scad_path
            result.final_stl_path = patched_art.stl_path
            result.final_views_dir = self._dir_of(patched_art.view_paths)

        # Materialise final.* convenience copies for downstream metric scripts.
        self._materialise_final(result)

        result.elapsed_s = time.time() - t0
        self._write_audit(
            result,
            extra={
                "baseline_report_chosen": _serialise_report(baseline_report),
                "baseline_reports_all": {
                    m: _serialise_report(r) for m, r in baseline_reports.items()
                },
                "patched_report": _serialise_report(patched_report) if patched_report else None,
                "kb_hint_present": kb_hint_text is not None,
            },
        )
        return result

    # ------------------------------------------------------------------
    # Private helpers
    # ------------------------------------------------------------------

    def _safe_assess(self, prompt: str, view_paths: dict, kb_hint: Optional[str]) -> GapReport:
        try:
            return self.assessor.assess(
                prompt=prompt,
                view_paths=view_paths,
                sketch_path=self.config.sketch_path,
                kb_hint=kb_hint,
            )
        except Exception as e:
            return GapReport(error=f"assessor exception: {e}")

    @staticmethod
    def _safe_model_label(model: str) -> str:
        """Filesystem-safe label for a model id (e.g. 'gpt-5.2' → 'gpt-5_2')."""
        return model.replace(".", "_").replace("/", "_")

    @staticmethod
    def _dir_of(view_paths: dict) -> str:
        if not view_paths:
            return ""
        first = next(iter(view_paths.values()))
        return os.path.dirname(first)

    @staticmethod
    def _materialise_final(result: V4Result) -> None:
        """Copy chosen artifacts to final.scad / final.stl / final_views/."""
        out_dir = result.out_dir
        # final.scad
        if result.final_scad_path and os.path.exists(result.final_scad_path):
            shutil.copyfile(result.final_scad_path, os.path.join(out_dir, "final.scad"))
        # final.stl
        if result.final_stl_path and os.path.exists(result.final_stl_path):
            shutil.copyfile(result.final_stl_path, os.path.join(out_dir, "final.stl"))
        # final_views/
        if result.final_views_dir and os.path.isdir(result.final_views_dir):
            dst = os.path.join(out_dir, "final_views")
            if os.path.isdir(dst):
                shutil.rmtree(dst)
            shutil.copytree(result.final_views_dir, dst)

    @staticmethod
    def _write_audit(result: V4Result, extra: Optional[Dict[str, Any]] = None) -> None:
        out = result.to_dict()
        if extra:
            out.update(extra)
        path = os.path.join(result.out_dir, "audit.json")
        with open(path, "w") as f:
            json.dump(out, f, indent=2, default=str)


def _serialise_report(report: Optional[GapReport]) -> Optional[Dict[str, Any]]:
    if report is None:
        return None
    return {
        "overall_judgement": report.overall_judgement,
        "num_pass": report.num_pass,
        "num_total": report.num_total,
        "fitness_proxy": report.fitness_proxy,
        "critical_issues": report.critical_issues,
        "minor_issues": report.minor_issues,
        "patch_priority": report.patch_priority,
        "acceptance_criteria": [
            {
                "id": c.id,
                "description": c.description,
                "verdict": c.verdict,
                "evidence": c.evidence,
            }
            for c in report.acceptance_criteria
        ],
        "error": report.error,
    }
