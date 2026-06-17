#!/usr/bin/env python3
"""
Step 4: Evaluate benchmark results for external datasets.

Compares generated STLs against ground truth STLs using 4 metrics:
  1. Chamfer Distance (CD) — normalized point-cloud distance
  2. F1-Score — surface coverage at 1% and 5% thresholds
  3. Voxel IoU — volumetric intersection over union
  4. SSIM + Silhouette IoU — image similarity (if PNGs available)

Reuses metric functions from evaluate_benchmark.py.
Produces per-model summaries, per-tier breakdowns, and comparison tables.

Prerequisites:
    - Steps 1-3 completed
    - pip install numpy trimesh scipy pillow

Usage:
    # Evaluate all models for Slice100K
    python ext_step4_evaluate.py \
        --benchmark-json slice100k_ground_truth.json \
        --results-dir results/ext_slice100k

    # Evaluate all models for ABC
    python ext_step4_evaluate.py \
        --benchmark-json abc_ground_truth.json \
        --results-dir results/ext_abc

    # Evaluate specific models only
    python ext_step4_evaluate.py \
        --benchmark-json slice100k_ground_truth.json \
        --results-dir results/ext_slice100k \
        --models craft gpt4o

    # Use GPU for Chamfer Distance
    python ext_step4_evaluate.py \
        --benchmark-json abc_ground_truth.json \
        --results-dir results/ext_abc \
        --gpu

Output:
    <output-dir>/detailed_results.json
    <output-dir>/summaries.json
    <output-dir>/comparison_table.md

Run order:
    1. python ext_step1_render_views.py   --stl-dir <...>
    2. python ext_step2_generate_ground_truth.py --stl-dir <...> --dataset-name <...>
    3. python ext_step3_run_benchmark.py  --benchmark-json <...> --dataset-name <...>
    4. python ext_step4_evaluate.py       --benchmark-json <...> --results-dir <...>  # This
"""

import os
import sys
import json
import argparse
import logging
from pathlib import Path
from typing import Dict, List

# Import metric functions from evaluate_benchmark.py
SCRIPT_DIR = Path(__file__).parent
REPO_ROOT = SCRIPT_DIR.parent.parent
sys.path.insert(0, str(REPO_ROOT / "experiments" / "03_metrics" / "_shared"))

from geometric import (
    MetricResult,
    ModelSummary,
    evaluate_single,
    save_results,
    print_summary,
    _compute_summary,
)

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(message)s',
    datefmt='%H:%M:%S',
)
logger = logging.getLogger(__name__)


def load_ground_truth(benchmark_json: str) -> Dict:
    """Load ground truth metadata from benchmark JSON."""
    with open(benchmark_json) as f:
        data = json.load(f)

    comp_meta = {}
    for comp in data.get("components", []):
        comp_meta[comp["id"]] = {
            "tier": comp.get("tier", ""),
            "family": comp.get("component_family", ""),
            "prompt": comp.get("prompt", ""),
            "stl_file": comp.get("stl_file", ""),
            "png_file": comp.get("png_file", ""),
        }

    return comp_meta


def discover_models(results_dir: Path) -> Dict[str, Path]:
    """
    Discover model result directories.

    Expected structure:
        results_dir/craft/stl/
        results_dir/gpt4o/stl/
        results_dir/gpt52/stl/
    """
    models = {}
    for subdir in sorted(results_dir.iterdir()):
        if subdir.is_dir() and (subdir / "stl").exists():
            models[subdir.name] = subdir / "stl"
    return models


def evaluate_external_model(
    comp_meta: Dict,
    pred_stl_dir: Path,
    model_name: str,
    pred_png_dir: Path = None,
    n_points: int = 10000,
    use_gpu: bool = False,
) -> tuple:
    """
    Evaluate a model against ground truth using external dataset.

    Key difference from evaluate_benchmark.py: ground truth STL paths come
    from the JSON (absolute paths) instead of a GT directory.
    """
    prompt_ids = sorted(comp_meta.keys())

    logger.info(f"Evaluating model '{model_name}': {len(prompt_ids)} prompts")

    results = []
    for i, pid in enumerate(prompt_ids):
        meta = comp_meta[pid]

        # Ground truth STL from JSON (absolute path)
        gt_stl = meta.get("stl_file", "")

        # Predicted STL from results directory
        pred_stl = str(pred_stl_dir / f"{pid}.stl")

        # PNG paths (optional, for SSIM)
        gt_png = meta.get("png_file", None)
        pred_png = str(pred_png_dir / f"{pid}.png") if pred_png_dir else None

        logger.info(f"  [{i+1}/{len(prompt_ids)}] {pid}")

        result = evaluate_single(
            gt_stl_path=gt_stl,
            pred_stl_path=pred_stl,
            prompt_id=pid,
            model_name=model_name,
            gt_png_path=gt_png if gt_png and os.path.exists(gt_png) else None,
            pred_png_path=pred_png if pred_png and os.path.exists(pred_png) else None,
            tier=meta.get("tier", ""),
            family=meta.get("family", ""),
            n_points=n_points,
            use_gpu=use_gpu,
        )

        results.append(result)

        if result.error:
            logger.warning(f"    ERROR: {result.error}")
        else:
            logger.info(
                f"    CD={result.chamfer_distance:.6f}  "
                f"F1@1%={result.f1_score_1pct:.4f}  "
                f"F1@5%={result.f1_score_5pct:.4f}  "
                f"VoxIoU={result.voxel_iou:.4f}  "
                f"({result.compute_time_s:.1f}s)"
            )

    summary = _compute_summary(results, model_name)
    return results, summary


def main():
    parser = argparse.ArgumentParser(
        description="Evaluate external dataset benchmark results",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Evaluate Slice100K results
  python ext_step4_evaluate.py \\
      --benchmark-json slice100k_ground_truth.json \\
      --results-dir results/ext_slice100k

  # Evaluate specific models
  python ext_step4_evaluate.py \\
      --benchmark-json abc_ground_truth.json \\
      --results-dir results/ext_abc \\
      --models craft gpt52
        """,
    )
    parser.add_argument("--benchmark-json", type=str, required=True,
                        help="Path to ground truth JSON from step 2")
    parser.add_argument("--results-dir", type=str, required=True,
                        help="Base results directory (contains model subdirectories)")
    parser.add_argument("--models", nargs="+", default=None,
                        help="Specific models to evaluate (default: auto-discover)")
    parser.add_argument("--output-dir", type=str, default=None,
                        help="Output directory (default: <results-dir>/evaluation)")
    parser.add_argument("--n-points", type=int, default=10000,
                        help="Points to sample for CD and F1 (default: 10000)")
    parser.add_argument("--gpu", action="store_true",
                        help="Use GPU for Chamfer Distance")
    args = parser.parse_args()

    if not os.path.exists(args.benchmark_json):
        print(f"Error: Benchmark JSON not found: {args.benchmark_json}")
        sys.exit(1)

    results_dir = Path(args.results_dir)
    if not results_dir.exists():
        print(f"Error: Results directory not found: {results_dir}")
        sys.exit(1)

    output_dir = args.output_dir or str(results_dir / "evaluation")

    # Load ground truth
    comp_meta = load_ground_truth(args.benchmark_json)
    print(f"Loaded {len(comp_meta)} ground truth samples from {args.benchmark_json}")

    # Discover or filter models
    available_models = discover_models(results_dir)
    if not available_models:
        print(f"Error: No model result directories found in {results_dir}")
        print("Expected structure: <results-dir>/<model>/stl/*.stl")
        sys.exit(1)

    if args.models:
        model_configs = {
            m: available_models[m]
            for m in args.models
            if m in available_models
        }
        missing = [m for m in args.models if m not in available_models]
        if missing:
            print(f"Warning: Models not found: {missing}")
            print(f"Available: {list(available_models.keys())}")
    else:
        model_configs = available_models

    print(f"Evaluating models: {list(model_configs.keys())}")

    # Get dataset info
    with open(args.benchmark_json) as f:
        gt_data = json.load(f)
    dataset_name = gt_data.get("dataset", "external")

    print(f"\n{'=' * 70}")
    print(f"External Dataset Evaluation: {dataset_name}")
    print(f"{'=' * 70}")

    # Evaluate each model
    all_results = {}
    all_summaries = {}

    for model_name, stl_dir in model_configs.items():
        print(f"\n{'=' * 60}")
        print(f"Evaluating: {model_name}")
        print(f"  STL dir: {stl_dir}")
        print(f"{'=' * 60}")

        # Check for PNG directory (for SSIM)
        png_dir = stl_dir.parent / "png"
        pred_png_dir = png_dir if png_dir.exists() else None

        results, summary = evaluate_external_model(
            comp_meta=comp_meta,
            pred_stl_dir=stl_dir,
            model_name=model_name,
            pred_png_dir=pred_png_dir,
            n_points=args.n_points,
            use_gpu=args.gpu,
        )

        all_results[model_name] = results
        all_summaries[model_name] = summary

    # Save results using existing infrastructure
    save_results(all_results, all_summaries, output_dir)

    # Print summary
    print_summary(all_summaries)

    # Print additional per-dataset info
    print(f"\nDataset: {dataset_name}")
    print(f"Ground truth samples: {len(comp_meta)}")
    print(f"Results saved to: {output_dir}")


if __name__ == "__main__":
    main()
