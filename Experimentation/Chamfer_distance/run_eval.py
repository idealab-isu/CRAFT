#!/usr/bin/env python3
"""
Run Chamfer-distance evaluation across 3 models vs ground-truth STLs.

Expected layout (all filenames matched by stem, e.g. `example_01.stl`):

    Experimentation/Chamfer_distance/
        stls/
            ground_truth/*.stl
            craft/*.stl
            gpt4o/*.stl
            gpt52/*.stl
        results/               # outputs written here

Usage
-----
    cd Experimentation/Chamfer_distance
    python run_eval.py                     # defaults: 10k points, full alignment
    python run_eval.py --n-points 20000
    python run_eval.py --no-icp            # faster; PCA + 24 rotations only
    python run_eval.py --methods craft gpt52

Outputs
-------
    results/cd_results.json     machine-readable per-example distances
    results/cd_summary.md       markdown table for the paper / quick read
"""

from __future__ import annotations

import argparse
import json
import logging
import sys
import time
from pathlib import Path
from typing import Dict, List

sys.path.insert(0, str(Path(__file__).parent))
from align_and_score import score_stl_pair  # noqa: E402

logging.basicConfig(level=logging.INFO, format="%(message)s")
logger = logging.getLogger("cd_eval")

HERE = Path(__file__).resolve().parent
STL_ROOT = HERE / "stls"
RESULTS_DIR = HERE / "results"
DEFAULT_METHODS = ["craft", "gpt52", "gpt4o"]


def discover_examples(gt_dir: Path) -> List[str]:
    """Return sorted example stems based on ground-truth STL filenames."""
    stems = sorted(p.stem for p in gt_dir.glob("*.stl"))
    if not stems:
        logger.error("No ground-truth STLs found in %s", gt_dir)
    return stems


def run(
    methods: List[str],
    n_points: int,
    use_icp: bool,
    seed: int,
) -> Dict:
    gt_dir = STL_ROOT / "ground_truth"
    examples = discover_examples(gt_dir)
    if not examples:
        sys.exit(1)

    RESULTS_DIR.mkdir(parents=True, exist_ok=True)

    per_example: Dict[str, Dict[str, Dict]] = {}
    logger.info("Examples: %s", examples)
    logger.info("Methods : %s", methods)
    logger.info("Points  : %d / ICP: %s\n", n_points, use_icp)

    for ex in examples:
        gt_stl = gt_dir / f"{ex}.stl"
        logger.info("=== %s ===", ex)
        per_example[ex] = {}

        for method in methods:
            pred_stl = STL_ROOT / method / f"{ex}.stl"
            if not pred_stl.exists():
                logger.info("  %-8s  MISSING (%s)", method, pred_stl.name)
                per_example[ex][method] = {"error": "missing_stl"}
                continue

            t0 = time.time()
            result = score_stl_pair(
                pred_stl=pred_stl,
                gt_stl=gt_stl,
                n_points=n_points,
                seed=seed,
                use_icp=use_icp,
            )
            dt = time.time() - t0

            if result is None:
                logger.info("  %-8s  FAILED to load", method)
                per_example[ex][method] = {"error": "load_failed"}
                continue

            logger.info(
                "  %-8s  CD=%.5f  (raw=%.5f, init#%d, %.1fs)",
                method,
                result.chamfer,
                result.chamfer_raw,
                result.best_init_index,
                dt,
            )
            per_example[ex][method] = {
                "chamfer": result.chamfer,
                "chamfer_raw": result.chamfer_raw,
                "best_init_index": result.best_init_index,
                "seconds": dt,
            }
        logger.info("")

    # ---- aggregate ----
    means: Dict[str, float] = {}
    for method in methods:
        vals = [
            per_example[ex][method]["chamfer"]
            for ex in examples
            if "chamfer" in per_example[ex].get(method, {})
        ]
        means[method] = sum(vals) / len(vals) if vals else float("nan")

    summary = {
        "config": {
            "n_points": n_points,
            "use_icp": use_icp,
            "seed": seed,
            "methods": methods,
            "examples": examples,
        },
        "per_example": per_example,
        "mean_chamfer": means,
    }

    # ---- write outputs ----
    json_path = RESULTS_DIR / "cd_results.json"
    json_path.write_text(json.dumps(summary, indent=2))
    logger.info("Wrote %s", json_path)

    md_path = RESULTS_DIR / "cd_summary.md"
    md_path.write_text(render_markdown(summary))
    logger.info("Wrote %s", md_path)

    # ---- print table ----
    logger.info("\n" + render_markdown(summary))
    return summary


def render_markdown(summary: Dict) -> str:
    methods = summary["config"]["methods"]
    examples = summary["config"]["examples"]
    per_example = summary["per_example"]
    means = summary["mean_chamfer"]

    lines: List[str] = []
    lines.append("# Chamfer Distance (aligned) — lower is better\n")
    cfg = summary["config"]
    lines.append(
        f"_Config: {cfg['n_points']} surface points, "
        f"ICP={'on' if cfg['use_icp'] else 'off'}, seed={cfg['seed']}, "
        f"normalized to unit bounding-sphere, PCA + 24 rotations alignment._\n"
    )

    header = "| example | " + " | ".join(methods) + " |"
    sep = "|---|" + "|".join(["---"] * len(methods)) + "|"
    lines.append(header)
    lines.append(sep)

    for ex in examples:
        row = [ex]
        # find best method in this row to bold
        valid = {
            m: per_example[ex][m]["chamfer"]
            for m in methods
            if "chamfer" in per_example[ex].get(m, {})
        }
        best = min(valid, key=valid.get) if valid else None
        for m in methods:
            cell = per_example[ex].get(m, {})
            if "chamfer" in cell:
                s = f"{cell['chamfer']:.5f}"
                if m == best:
                    s = f"**{s}**"
                row.append(s)
            else:
                row.append(cell.get("error", "—"))
        lines.append("| " + " | ".join(row) + " |")

    lines.append("")
    lines.append("## Mean Chamfer Distance")
    lines.append("| method | mean CD |")
    lines.append("|---|---|")
    for m in methods:
        v = means.get(m, float("nan"))
        lines.append(f"| {m} | {v:.5f} |")

    return "\n".join(lines) + "\n"


def parse_args():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--methods", nargs="+", default=DEFAULT_METHODS,
                    help="Subdirectories under stls/ to evaluate.")
    ap.add_argument("--n-points", type=int, default=10_000,
                    help="Surface points sampled from each mesh.")
    ap.add_argument("--no-icp", action="store_true",
                    help="Disable ICP refinement (faster; PCA + 24 rotations only).")
    ap.add_argument("--seed", type=int, default=42)
    return ap.parse_args()


def main():
    args = parse_args()
    run(
        methods=args.methods,
        n_points=args.n_points,
        use_icp=not args.no_icp,
        seed=args.seed,
    )


if __name__ == "__main__":
    main()
