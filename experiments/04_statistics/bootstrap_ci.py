#!/usr/bin/env python3
"""
Bootstrap 95% confidence intervals for every metric where per-sample data
exists (CD, F1@1%, F1@5%, Voxel IoU, SSIM, CLIP, Hausdorff, NC, LPIPS).

Reads the per-sample detailed_results.json / *_detailed_results.json that the
metric scripts wrote, resamples with replacement (n_resamples, default 1000),
and writes a single ci.json into each metric directory.

Usage:
  python experiments/04_statistics/bootstrap_ci.py --dataset nopscadlib
  python experiments/04_statistics/bootstrap_ci.py --dataset abc --n-resamples 2000
"""
from __future__ import annotations

import argparse
import json
import logging
from collections import defaultdict
from pathlib import Path
from typing import Dict, List, Optional

import numpy as np

SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parent.parent
METRICS = REPO_ROOT / "metrics"

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger("bootstrap")


# Each entry: (relative_path_under_metrics/<dataset>, list of (field, lower_is_better))
# ONLY metrics that appear in the paper (CD, F1, Voxel IoU, CLIP) and the new
# rebuttal-promised editability metrics. HD/NC/LPIPS are NOT in the paper and
# are deliberately excluded.
SOURCES = [
    ("detailed_results.json", [
        ("chamfer_distance",  True),
        ("f1_score_1pct",     False),
        ("f1_score_5pct",     False),
        ("voxel_iou",         False),
    ]),
    ("clip/clip_detailed_results.json", [("clip_score", False)]),
    ("editability/editability_detailed.json", [
        ("symbolic_preservation_rate",   False),
        ("edit_success_rate",            False),
        ("post_edit_render_validity",    False),
    ]),
]


def normalize_records(raw) -> List[dict]:
    """
    Normalize a detailed-results file into a flat list of records that each
    carry a 'method' field. Accepts:
      - flat list of dicts (each already has 'method' or 'model_name' or 'source')
      - dict keyed by method → list of dicts (the per-record dict need not name itself)
    """
    out: List[dict] = []
    if isinstance(raw, list):
        for r in raw:
            if not isinstance(r, dict):
                continue
            m = r.get("method") or r.get("model_name") or r.get("source") or "unknown"
            r = dict(r)
            r["method"] = m
            out.append(r)
    elif isinstance(raw, dict):
        for k, v in raw.items():
            if not isinstance(v, list):
                continue
            for r in v:
                if not isinstance(r, dict):
                    continue
                r = dict(r)
                r.setdefault("method", r.get("model_name") or r.get("source") or k)
                out.append(r)
    return out


def bootstrap_ci(
    values: List[float], n_resamples: int = 1000, alpha: float = 0.05, rng: np.random.Generator = None,
) -> Dict[str, float]:
    if rng is None:
        rng = np.random.default_rng(42)
    arr = np.asarray([v for v in values if v is not None and not (isinstance(v, float) and np.isnan(v))],
                     dtype=np.float64)
    n = arr.size
    if n == 0:
        return {"n": 0, "mean": None, "ci_low": None, "ci_high": None}
    if n == 1:
        return {"n": 1, "mean": float(arr[0]), "ci_low": float(arr[0]), "ci_high": float(arr[0])}
    idx = rng.integers(0, n, size=(n_resamples, n))
    boot_means = arr[idx].mean(axis=1)
    return {
        "n": int(n),
        "mean": float(arr.mean()),
        "median": float(np.median(arr)),
        "ci_low":  float(np.quantile(boot_means, alpha / 2)),
        "ci_high": float(np.quantile(boot_means, 1 - alpha / 2)),
    }


def process_metric(
    detail_path: Path, fields, dataset: str, n_resamples: int,
) -> None:
    if not detail_path.exists():
        log.info("skip %s (file does not exist)", detail_path.relative_to(REPO_ROOT))
        return
    log.info("processing %s", detail_path.relative_to(REPO_ROOT))
    raw = json.loads(detail_path.read_text())
    records = normalize_records(raw)
    if not records:
        log.info("  (no records after normalization, skipping)")
        return

    # Group per-sample values by (method, tier) AND per-method overall
    by_method: Dict[str, Dict[str, List]] = defaultdict(lambda: defaultdict(list))
    by_method_tier: Dict[str, Dict[str, Dict[str, List]]] = defaultdict(lambda: defaultdict(lambda: defaultdict(list)))
    for r in records:
        if not r.get("success", True):
            continue
        method = r["method"]
        tier   = r.get("tier", "all")
        for field_name, _lower in fields:
            v = r.get(field_name)
            if v is None:
                continue
            # Drop NaN explicitly — some CLIP / metric runs have NaN on blank renders
            if isinstance(v, float) and (v != v):
                continue
            by_method[method][field_name].append(v)
            by_method_tier[method][tier][field_name].append(v)

    rng = np.random.default_rng(42)
    out = {
        "dataset": dataset,
        "source_file": str(detail_path.relative_to(REPO_ROOT)),
        "n_resamples": n_resamples,
        "alpha": 0.05,
        "per_method": {},
        "per_method_tier": {},
    }
    for method, fields_map in by_method.items():
        out["per_method"][method] = {
            fname: bootstrap_ci(vals, n_resamples=n_resamples, rng=rng)
            for fname, vals in fields_map.items()
        }
    for method, tier_map in by_method_tier.items():
        out["per_method_tier"][method] = {}
        for tier, fields_map in tier_map.items():
            out["per_method_tier"][method][tier] = {
                fname: bootstrap_ci(vals, n_resamples=n_resamples, rng=rng)
                for fname, vals in fields_map.items()
            }

    # Write ci.json next to the source file (i.e. in its parent directory)
    out_path = detail_path.parent / "ci.json"
    out_path.write_text(json.dumps(out, indent=2))
    log.info("  → wrote %s", out_path.relative_to(REPO_ROOT))


def main() -> int:
    parser = argparse.ArgumentParser(description="Bootstrap CIs across metrics")
    parser.add_argument("--dataset", choices=["nopscadlib", "abc", "slice100k"], required=True)
    parser.add_argument("--n-resamples", type=int, default=1000)
    args = parser.parse_args()

    dataset_dir = METRICS / args.dataset
    for rel_path, fields in SOURCES:
        detail_path = dataset_dir / rel_path
        process_metric(detail_path, fields, args.dataset, args.n_resamples)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
