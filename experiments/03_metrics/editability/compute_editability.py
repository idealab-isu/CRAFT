#!/usr/bin/env python3
"""
Editability metrics for generated parametric CAD models.

For every .scad file in each method's output directory, computes:

  1. exposed_parameter_count       — # of top-level customizer parameters
  2. symbolic_preservation_rate    — fraction of secondary assignments whose
                                     RHS references another identifier with an
                                     arithmetic operator (i.e., genuinely
                                     symbolic, not hardcoded literals)
  3. edit_success_rate             — for each exposed param, perturb ±10%/±50%,
                                     re-render, and count successes. Rate =
                                     successes / (n_params · n_perturbations)
  4. post_edit_render_validity     — fraction of attempted edits whose rendered
                                     PNG is non-trivial (exit code 0, file
                                     exists, mean foreground > 0.5%)

Outputs:
  metrics/<dataset>/editability/editability_detailed.json    (per sample)
  metrics/<dataset>/editability/editability_summaries.json   (per method + per tier)
  metrics/<dataset>/editability/editability_scores.csv       (wide CSV)
  metrics/<dataset>/editability/editability_comparison_table.md

Usage:
  python experiments/03_metrics/editability/compute_editability.py \\
      --scad-dirs craft=results/nopscadlib/craft/scad \\
                  gpt4o=results/nopscadlib/baselines/gpt4o/scad \\
                  gpt52=results/nopscadlib/baselines/gpt52/scad \\
      --benchmark-json ground_truth/nopscadlib/benchmark_ground_truth.json \\
      --perturbations 10 50 \\
      --output-dir metrics/nopscadlib/editability

  # Skip render checks (fast, gives you metrics 1 & 2 only)
  python experiments/03_metrics/editability/compute_editability.py ... --no-render

Requires: pipeline/utils/parameter_parser, pipeline/utils/openscad_runner,
PIL. OpenSCAD must be on $PATH for metrics (3) and (4).
"""
from __future__ import annotations

import argparse
import json
import logging
import re
import sys
import tempfile
import time
from collections import defaultdict
from dataclasses import asdict, dataclass, field
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Tuple

SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parent.parent.parent
sys.path.insert(0, str(REPO_ROOT / "pipeline"))

from utils.parameter_parser import parse_parameters_from_scad, update_multiple_parameters  # noqa: E402
from utils.openscad_runner import OpenScadRunner, RenderMode  # noqa: E402

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger("editability")


# Regex: `identifier = <something containing identifier(s) and an arithmetic op>;`
ASSIGN_RE = re.compile(
    r"^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*([^;]+?)\s*;\s*(?://.*)?$",
    re.MULTILINE,
)
IDENT_RE = re.compile(r"[A-Za-z_][A-Za-z0-9_]*")
ARITH_RE = re.compile(r"[+\-*/%]")


@dataclass
class SampleEdit:
    """Result of a single (param, perturbation) edit attempt."""
    param: str
    perturbation_pct: int
    original_value: Optional[float]
    new_value: Optional[float]
    render_ok: bool
    valid: bool      # render_ok AND non-trivial PNG
    error: Optional[str] = None


@dataclass
class SampleResult:
    prompt_id: str
    method: str
    tier: str
    family: str
    exposed_parameter_count: int = 0
    symbolic_assignments: int = 0
    nonsymbolic_assignments: int = 0
    symbolic_preservation_rate: float = 0.0
    edits: List[SampleEdit] = field(default_factory=list)
    edit_success_rate: Optional[float] = None
    post_edit_render_validity: Optional[float] = None


def load_metadata(json_path: Path) -> Dict[str, Dict]:
    """Per-prompt metadata: tier, family. Optional."""
    if not json_path.exists():
        return {}
    with json_path.open() as f:
        data = json.load(f)
    out: Dict[str, Dict] = {}
    for comp in data.get("components", []):
        out[comp["id"]] = {
            "tier": comp.get("tier", "unknown"),
            "family": comp.get("component_family", "unknown"),
        }
    return out


def measure_symbolic_preservation(scad: str, exposed_param_names: List[str]) -> Tuple[int, int]:
    """
    Return (symbolic_count, nonsymbolic_count) of "secondary" assignments —
    i.e., assignments whose LHS is NOT one of the exposed top-level params.
    """
    symbolic = nonsymbolic = 0
    exposed_set = set(exposed_param_names)
    for m in ASSIGN_RE.finditer(scad):
        lhs, rhs = m.group(1), m.group(2).strip()
        if lhs in exposed_set:
            continue  # skip exposed param definitions themselves
        # Find identifier references on the RHS (excluding numbers, $fn, etc.)
        ids = [i for i in IDENT_RE.findall(rhs) if i not in {"true", "false"} and not i.startswith("$")]
        has_ref = any(i in exposed_set or i != lhs for i in ids) and len(ids) > 0
        has_op  = bool(ARITH_RE.search(rhs))
        if has_ref and has_op:
            symbolic += 1
        else:
            nonsymbolic += 1
    return symbolic, nonsymbolic


def is_png_nontrivial(png_path: Path, threshold: float = 0.005) -> bool:
    """True iff PNG exists and has at least `threshold` fraction non-white pixels."""
    if not png_path.exists() or png_path.stat().st_size == 0:
        return False
    try:
        from PIL import Image
        import numpy as np
        img = Image.open(png_path).convert("L")
        arr = np.asarray(img, dtype=np.float32) / 255.0
        # OpenSCAD's preview default is a light background; non-trivial = some darker pixels
        non_bg = (arr < 0.95).mean()
        return float(non_bg) > threshold
    except Exception:
        return False


def render_to_tmp(scad_text: str, work_dir: Path, timeout: int = 60) -> Tuple[bool, bool]:
    """
    Write the modified SCAD to a temp file under work_dir and render it.
    Returns (render_ok, png_valid).
    """
    work_dir.mkdir(parents=True, exist_ok=True)
    scad_path = work_dir / "edit.scad"
    png_path = work_dir / "edit.png"
    scad_path.write_text(scad_text, encoding="utf-8")
    runner = OpenScadRunner(str(scad_path), str(png_path), render_mode=RenderMode.preview, timeout=timeout)
    render_ok = runner.run()
    valid = render_ok and is_png_nontrivial(png_path)
    return render_ok, valid


def perturb_value(value: float, pct: int, signed: int = 1) -> float:
    """Perturb a numeric value by ±pct%. signed = +1 or -1."""
    delta = abs(value) * (pct / 100.0) if value != 0 else (pct / 100.0)
    return value + signed * delta


def measure_edits(
    scad: str, params: List[dict], perturbations: List[int],
    work_dir: Path, render_timeout: int = 60,
) -> List[SampleEdit]:
    edits: List[SampleEdit] = []
    for p in params:
        name = p["name"]
        try:
            orig = float(p["value"])
        except (TypeError, ValueError):
            continue  # skip non-numeric params
        for pct in perturbations:
            for signed in (-1, 1):
                new_val = perturb_value(orig, pct, signed)
                signed_pct = signed * pct
                try:
                    edited = update_multiple_parameters(scad, {name: new_val})
                    render_ok, valid = render_to_tmp(edited, work_dir, timeout=render_timeout)
                    edits.append(SampleEdit(
                        param=name, perturbation_pct=signed_pct,
                        original_value=orig, new_value=new_val,
                        render_ok=render_ok, valid=valid,
                    ))
                except Exception as e:
                    edits.append(SampleEdit(
                        param=name, perturbation_pct=signed_pct,
                        original_value=orig, new_value=new_val,
                        render_ok=False, valid=False, error=str(e),
                    ))
    return edits


def analyze_sample(
    scad_path: Path, method: str, metadata: Dict[str, Dict],
    perturbations: List[int], do_render: bool,
    work_root: Path, render_timeout: int,
) -> SampleResult:
    prompt_id = scad_path.stem
    meta = metadata.get(prompt_id, {"tier": "unknown", "family": "unknown"})
    sr = SampleResult(prompt_id=prompt_id, method=method, tier=meta["tier"], family=meta["family"])

    # Some generated SCAD was written by Windows in cp1252 (pre-PYTHONUTF8 runs)
    # and may contain bytes like 0x96 (en-dash) in comments. Tolerant read:
    # parameter lines are pure ASCII, so replacement chars never affect parsing.
    scad = scad_path.read_text(encoding="utf-8", errors="replace")
    params = parse_parameters_from_scad(scad)
    sr.exposed_parameter_count = len(params)

    sym, nonsym = measure_symbolic_preservation(scad, [p["name"] for p in params])
    sr.symbolic_assignments = sym
    sr.nonsymbolic_assignments = nonsym
    total = sym + nonsym
    sr.symbolic_preservation_rate = sym / total if total else 0.0

    if do_render and params:
        # Limit to 4 params per sample to keep wall time reasonable on big datasets
        params_to_edit = params[:4]
        edits = measure_edits(
            scad, params_to_edit, perturbations,
            work_dir=work_root / method / prompt_id,
            render_timeout=render_timeout,
        )
        sr.edits = edits
        if edits:
            sr.edit_success_rate = sum(1 for e in edits if e.render_ok) / len(edits)
            sr.post_edit_render_validity = sum(1 for e in edits if e.valid) / len(edits)
    return sr


def summarize_method(samples: List[SampleResult]) -> Dict:
    if not samples:
        return {}
    n = len(samples)
    return {
        "n_samples": n,
        "mean_exposed_parameters": sum(s.exposed_parameter_count for s in samples) / n,
        "symbolic_preservation_rate": sum(s.symbolic_preservation_rate for s in samples) / n,
        "edit_success_rate": _mean_optional(s.edit_success_rate for s in samples),
        "post_edit_render_validity": _mean_optional(s.post_edit_render_validity for s in samples),
    }


def _mean_optional(values) -> Optional[float]:
    vs = [v for v in values if v is not None]
    return sum(vs) / len(vs) if vs else None


def main() -> int:
    parser = argparse.ArgumentParser(description="Compute editability metrics from SCAD outputs")
    parser.add_argument(
        "--scad-dirs", nargs="+", required=True,
        help='List of name=path pairs, e.g. craft=results/nopscadlib/craft/scad',
    )
    parser.add_argument("--benchmark-json", type=Path,
                        help="Optional metadata JSON for per-tier breakdown")
    parser.add_argument("--perturbations", type=int, nargs="+", default=[10, 50],
                        help="Perturbation percentages to apply per param (default: 10 50)")
    parser.add_argument("--no-render", action="store_true",
                        help="Skip render-based metrics (3,4); compute (1,2) only")
    parser.add_argument("--render-timeout", type=int, default=60)
    parser.add_argument("--max-samples", type=int, help="Smoke-test on first N samples per method")
    parser.add_argument("--output-dir", type=Path, required=True)
    args = parser.parse_args()

    args.output_dir.mkdir(parents=True, exist_ok=True)
    metadata = load_metadata(args.benchmark_json) if args.benchmark_json else {}
    work_root = Path(tempfile.mkdtemp(prefix="craft_editability_"))
    log.info("temp work dir: %s", work_root)

    all_samples: List[SampleResult] = []
    per_method_summaries: Dict[str, Dict] = {}
    per_method_tier_summaries: Dict[str, Dict[str, Dict]] = {}

    for spec in args.scad_dirs:
        if "=" not in spec:
            sys.exit(f"--scad-dirs entries must be name=path; got {spec!r}")
        method, scad_dir = spec.split("=", 1)
        scad_dir = Path(scad_dir)
        files = sorted(scad_dir.glob("*.scad"))
        if args.max_samples:
            files = files[: args.max_samples]
        log.info("method=%s scanning %d SCAD files in %s", method, len(files), scad_dir)

        method_samples: List[SampleResult] = []
        for i, p in enumerate(files):
            if i % 25 == 0:
                log.info("  [%s] %d/%d", method, i, len(files))
            sr = analyze_sample(
                p, method, metadata, args.perturbations, do_render=not args.no_render,
                work_root=work_root, render_timeout=args.render_timeout,
            )
            method_samples.append(sr)
            all_samples.append(sr)

        per_method_summaries[method] = summarize_method(method_samples)
        per_tier: Dict[str, List[SampleResult]] = defaultdict(list)
        for s in method_samples:
            per_tier[s.tier].append(s)
        per_method_tier_summaries[method] = {t: summarize_method(v) for t, v in per_tier.items()}

    # Persist ------------------------------------------------------------------
    detailed_path = args.output_dir / "editability_detailed.json"
    summary_path  = args.output_dir / "editability_summaries.json"
    csv_path      = args.output_dir / "editability_scores.csv"
    md_path       = args.output_dir / "editability_comparison_table.md"

    detailed_path.write_text(json.dumps([asdict(s) for s in all_samples], indent=2))
    summary_path.write_text(json.dumps({
        "produced_at": datetime.now().isoformat(),
        "perturbations": args.perturbations,
        "render_enabled": not args.no_render,
        "methods": per_method_summaries,
        "methods_by_tier": per_method_tier_summaries,
    }, indent=2))

    methods = [s.split("=", 1)[0] for s in args.scad_dirs]
    by_pid: Dict[str, Dict[str, SampleResult]] = defaultdict(dict)
    for s in all_samples:
        by_pid[s.prompt_id][s.method] = s
    with csv_path.open("w") as f:
        f.write("prompt_id,tier," + ",".join(
            f"{m}_params,{m}_symbolic,{m}_edit_success,{m}_render_valid" for m in methods
        ) + "\n")
        for pid in sorted(by_pid):
            row = by_pid[pid]
            first = next(iter(row.values()))
            tier = first.tier
            cells = [pid, tier]
            for m in methods:
                s = row.get(m)
                if s is None:
                    cells += ["", "", "", ""]
                else:
                    cells += [
                        str(s.exposed_parameter_count),
                        f"{s.symbolic_preservation_rate:.4f}",
                        "" if s.edit_success_rate is None else f"{s.edit_success_rate:.4f}",
                        "" if s.post_edit_render_validity is None else f"{s.post_edit_render_validity:.4f}",
                    ]
            f.write(",".join(cells) + "\n")

    # Markdown table
    lines = ["# Editability Comparison\n",
             "| Method | n | Mean # params | Symbolic ↑ | Edit success ↑ | Render valid ↑ |",
             "|---|---:|---:|---:|---:|---:|"]
    for m, s in per_method_summaries.items():
        lines.append(
            f"| {m} | {s.get('n_samples', 0)} | "
            f"{s.get('mean_exposed_parameters', 0):.1f} | "
            f"{s.get('symbolic_preservation_rate', 0):.3f} | "
            f"{(s.get('edit_success_rate') or 0):.3f} | "
            f"{(s.get('post_edit_render_validity') or 0):.3f} |"
        )
    md_path.write_text("\n".join(lines) + "\n")

    log.info("done. wrote %s, %s, %s, %s", detailed_path, summary_path, csv_path, md_path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
