"""Top-level orchestrator for the Zero-to-CAD comparison eval.

One CLI that drives Phase 4 (pilot) → Phase 5 (headline) → Phase 6 (ablations)
→ Phase 7 (stretch). Each phase is a different (--phase, --benchmark, --method,
--limit) tuple; the runner is the same in every case.

Typical use:

    # Phase 4 pilot — 50 samples per method, ZTC test split
    python -m Experimentation.zerotocad_eval.run_eval \\
        --phase pilot --benchmark ztc_test \\
        --methods craft_v3 gpt52_openscad gpt52_cadquery their_qwen \\
        --score

    # Phase 5 headline (1K samples)
    python -m Experimentation.zerotocad_eval.run_eval \\
        --phase headline --benchmark ztc_test \\
        --methods craft_v3 gpt52_openscad gpt52_cadquery their_qwen \\
        --score

    # Phase 6 ablation: CRAFT v3 without the v3 gap-refinement step
    USE_VLM_CORRECTION=False python -m Experimentation.zerotocad_eval.run_eval \\
        --phase ablation --benchmark ztc_test --methods craft_v3 \\
        --tag craft_v3_no_vlm --limit 1000 --score

    # Phase 7 stretch — full 10K ZTC test split
    python -m Experimentation.zerotocad_eval.run_eval \\
        --phase stretch --benchmark ztc_test \\
        --methods craft_v3 gpt52_openscad gpt52_cadquery their_qwen \\
        --score

After --score finishes, summary tables are written to
`results/zerotocad_eval/metrics/{benchmark}/{phase}_summary.md`.

This script DOES NOT pull the dataset — run `fetch_ztc_test.py` first
(and an analogous ABC fetcher when we get there).
"""

from __future__ import annotations

import argparse
import json
import statistics
import sys
import time
from pathlib import Path
from typing import Dict, List, Optional


_HERE = Path(__file__).resolve()
_REPO_ROOT = _HERE.parents[2]


# --- phase → sample-limit policy from plan §10/§6 -------------------------
PHASE_LIMITS = {
    "pilot": 50,           # Phase 4: decision gate
    "headline": 1000,      # Phase 5: paper's headline number
    "ablation": 1000,      # Phase 6: per-ablation sample count
    "stretch": 10000,      # Phase 7: full ZTC test split
    "smoke": 5,            # opportunistic: validates wiring end-to-end
}

# --- benchmark → data-root resolver --------------------------------------
def _benchmark_data_root(benchmark: str) -> Path:
    return _REPO_ROOT / "Experimentation/zerotocad_eval/data" / benchmark


# --- per-method invocation ------------------------------------------------
def _invoke_runner(method: str, benchmark: str, data_root: Path,
                   out_root: Path, limit: int, force: bool) -> int:
    """Spawn the appropriate runner as a subprocess and wait for it.

    Subprocess (not in-process) because the runners pull in heavy deps
    (transformers/torch for their_qwen, full CRAFT for craft_v3) and we
    don't want to import them all at once.
    """
    import subprocess

    cmd: List[str] = [sys.executable, "-m"]
    if method == "craft_v3":
        cmd += ["Experimentation.zerotocad_eval.runners.run_craft"]
    elif method == "gpt52_cadquery":
        cmd += ["Experimentation.zerotocad_eval.runners.run_gpt5_baseline",
                "--output-lang", "cadquery", "--benchmark", benchmark]
    elif method == "gpt52_openscad":
        cmd += ["Experimentation.zerotocad_eval.runners.run_gpt5_baseline",
                "--output-lang", "openscad", "--benchmark", benchmark]
    elif method == "their_qwen":
        cmd += ["Experimentation.zerotocad_eval.runners.run_their_qwen",
                "--benchmark", benchmark]
    else:
        sys.stderr.write(f"Unknown method: {method}\n")
        return 1

    cmd += ["--data-root", str(data_root),
            "--out-root", str(out_root),
            "--limit", str(limit)]
    if force:
        cmd.append("--force")

    print(f"\n=== invoking {method} ===")
    print(" ".join(cmd))
    return subprocess.run(cmd, cwd=_REPO_ROOT).returncode


# --- scoring + summary ---------------------------------------------------
def _score_and_summarize(benchmark: str, methods: List[str], tag: Optional[str],
                         data_root: Path, results_root: Path,
                         skip_cd: bool) -> Path:
    """Run score_sample on every (method, uuid) that exists; aggregate."""
    from .score_sample import score_one

    summary: Dict[str, Dict[str, list]] = {}
    method_dirs: Dict[str, Path] = {}

    for method in methods:
        m_tag = tag if tag and len(methods) == 1 else method
        mdir = results_root / benchmark / m_tag
        if not mdir.exists():
            print(f"[score] skipping {m_tag} — no outputs at {mdir}")
            continue
        method_dirs[m_tag] = mdir
        summary[m_tag] = {"voxel_iou": [], "success": [], "cd": [], "editability": []}

    for m_tag, mdir in method_dirs.items():
        uuids = sorted([d for d in mdir.iterdir() if d.is_dir()])
        print(f"[score] {m_tag}: {len(uuids)} samples")
        for udir in uuids:
            gt = data_root / udir.name / "gt.stl"
            if not gt.exists():
                continue
            res = score_one(gt, udir, include_cd=not skip_cd)
            (udir / "metrics.json").write_text(json.dumps(res, indent=2))
            summary[m_tag]["voxel_iou"].append(res["voxel_iou"]["iou"])
            summary[m_tag]["success"].append(1 if res["success_rate"]["success"] else 0)
            if res.get("cd") and res["cd"].get("cd") is not None:
                summary[m_tag]["cd"].append(res["cd"]["cd"])
            if res.get("editability") and res["editability"].get("editability") is not None:
                summary[m_tag]["editability"].append(res["editability"]["editability"])

    metrics_dir = results_root / "metrics" / benchmark
    metrics_dir.mkdir(parents=True, exist_ok=True)
    summary_path = metrics_dir / f"{tag or 'summary'}.md"
    summary_json_path = metrics_dir / f"{tag or 'summary'}.json"

    def _stat(xs: list) -> Dict[str, Optional[float]]:
        if not xs:
            return {"n": 0, "mean": None, "median": None, "p90": None}
        sxs = sorted(xs)
        return {
            "n": len(xs),
            "mean": statistics.fmean(xs),
            "median": statistics.median(xs),
            "p90": sxs[max(0, int(round(0.9 * len(sxs))) - 1)],
        }

    table_lines = [
        f"# Zero-to-CAD eval — {benchmark} — {tag or 'all methods'}",
        "",
        f"_Scored {sum(len(v['success']) for v in summary.values())} samples across "
        f"{len(summary)} methods._",
        "",
        "| Method | n | Success | Mean IoU | Median IoU | P90 IoU | Mean CD | Mean Editability |",
        "|--------|---|---------|----------|------------|---------|---------|------------------|",
    ]

    def _fmt(x, spec=".3f"):
        return format(x, spec) if isinstance(x, (int, float)) else "n/a"

    summary_json: Dict[str, Dict[str, object]] = {}
    for m_tag, sums in summary.items():
        # `voxel_iou` is the only metric we score for EVERY sample (even
        # failures, which get iou=0.0), so its n is the denominator for
        # the success rate.
        n = len(sums["success"])
        iou = _stat(sums["voxel_iou"])
        cd = _stat(sums["cd"])
        edit = _stat(sums["editability"])
        success = (sum(sums["success"]) / n) if n else 0.0
        if n == 0:
            table_lines.append(
                f"| {m_tag} | 0 | n/a | n/a | n/a | n/a | n/a | n/a |"
            )
        else:
            table_lines.append(
                f"| {m_tag} | {n} | {success * 100:.1f}% | "
                f"{_fmt(iou['mean'])} | {_fmt(iou['median'])} | {_fmt(iou['p90'])} | "
                f"{_fmt(cd['mean'], '.4f')} | {_fmt(edit['mean'])} |"
            )
        summary_json[m_tag] = {
            "n": n, "success_rate": success,
            "voxel_iou": iou, "cd": cd, "editability": edit,
        }

    summary_path.write_text("\n".join(table_lines) + "\n")
    summary_json_path.write_text(json.dumps(summary_json, indent=2))
    print(f"\n[score] wrote {summary_path}")
    return summary_path


# --- main -----------------------------------------------------------------
def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--phase",
                        choices=list(PHASE_LIMITS.keys()),
                        required=True)
    parser.add_argument("--benchmark", required=True,
                        help="Benchmark name (matches data root subfolder).")
    parser.add_argument("--methods", nargs="+", required=True,
                        choices=["craft_v3", "gpt52_cadquery", "gpt52_openscad", "their_qwen"])
    parser.add_argument("--limit", type=int, default=None,
                        help="Override the phase's default sample limit.")
    parser.add_argument("--tag", default=None,
                        help="Override the method tag in the output path "
                        "(useful for ablations like 'craft_v3_no_vlm').")
    parser.add_argument("--force", action="store_true",
                        help="Re-run samples that already have output.")
    parser.add_argument("--skip-runners", action="store_true",
                        help="Skip generation; just score what's already on disk.")
    parser.add_argument("--score", action="store_true",
                        help="Score outputs and write summary table.")
    parser.add_argument("--skip-cd", action="store_true",
                        help="Skip aligned-CD when scoring (faster).")
    args = parser.parse_args()

    if args.tag and len(args.methods) > 1:
        sys.stderr.write("--tag may only be used with a single --method.\n")
        return 1

    limit = args.limit if args.limit is not None else PHASE_LIMITS[args.phase]

    data_root = _benchmark_data_root(args.benchmark)
    if not data_root.exists():
        sys.stderr.write(
            f"Data root not found: {data_root}\n"
            "Run `python -m Experimentation.zerotocad_eval.fetch_ztc_test` first.\n"
        )
        return 1

    results_root = _REPO_ROOT / "results" / "zerotocad_eval"

    # Generation pass
    if not args.skip_runners:
        for method in args.methods:
            out_tag = args.tag if (args.tag and len(args.methods) == 1) else method
            out_root = results_root / args.benchmark / out_tag
            rc = _invoke_runner(method, args.benchmark, data_root, out_root,
                                limit=limit, force=args.force)
            if rc != 0:
                sys.stderr.write(f"[{method}] runner exited {rc}\n")

    # Scoring pass
    if args.score:
        _score_and_summarize(
            args.benchmark, args.methods, args.tag, data_root, results_root,
            skip_cd=args.skip_cd,
        )

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
