#!/usr/bin/env python3
"""
Bootstrap confidence intervals for FID by resampling the matched feature set.

FID is distributional (one number per method, not per sample), so we can't
naively bootstrap-mean it. Instead we resample the matched (gt, pred) feature
indices with replacement, recompute (μ, Σ) on each resample, and recompute
FID — 1,000 resamples by default. Caches the Inception features on disk so
re-runs are cheap.

Usage:
  python experiments/04_statistics/fid_bootstrap.py --dataset nopscadlib
  python experiments/04_statistics/fid_bootstrap.py --dataset nopscadlib --n-resamples 2000

Requires that `experiments/03_metrics/fid/compute_fid.py` has been run at
least once (to populate the cached feature arrays).
"""
from __future__ import annotations

import argparse
import json
import logging
import sys
from pathlib import Path
from typing import Dict, List, Tuple

import numpy as np

SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parent.parent
METRICS = REPO_ROOT / "metrics"

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger("fid_bootstrap")


def fid_from_features(gt_feat: np.ndarray, pred_feat: np.ndarray) -> float:
    """Standard FID on two sets of 2048-d Inception features."""
    from scipy import linalg
    mu_g, sig_g = gt_feat.mean(axis=0), np.cov(gt_feat, rowvar=False)
    mu_p, sig_p = pred_feat.mean(axis=0), np.cov(pred_feat, rowvar=False)
    diff = mu_g - mu_p
    covmean, _ = linalg.sqrtm(sig_g @ sig_p, disp=False)
    if np.iscomplexobj(covmean):
        covmean = covmean.real
    return float(diff @ diff + np.trace(sig_g) + np.trace(sig_p) - 2 * np.trace(covmean))


def load_features(cache_dir: Path) -> Dict[str, np.ndarray]:
    """Load any cached *_features.npz under <metrics>/nopscadlib/fid/_cache/."""
    out: Dict[str, np.ndarray] = {}
    if not cache_dir.exists():
        return out
    for f in sorted(cache_dir.glob("*_features.npz")):
        # Convention from compute_fid.py: <name>_features.npz contains array 'features'
        try:
            arr = np.load(f)["features"]
        except KeyError:
            log.warning("cache %s missing 'features' key, skipping", f)
            continue
        name = f.stem.replace("_features", "")
        out[name] = arr.astype(np.float64)
    return out


def bootstrap_one(
    gt_feat: np.ndarray, pred_feat: np.ndarray,
    n_resamples: int, alpha: float, rng: np.random.Generator,
) -> Dict[str, float]:
    n = min(len(gt_feat), len(pred_feat))
    if n < 30:
        return {"point": fid_from_features(gt_feat[:n], pred_feat[:n]),
                "ci_low": None, "ci_high": None, "n_pairs": int(n), "n_resamples": 0}
    fids = []
    for _ in range(n_resamples):
        idx = rng.integers(0, n, size=n)
        try:
            fids.append(fid_from_features(gt_feat[idx], pred_feat[idx]))
        except Exception as e:
            log.warning("resample failed: %s", e)
    fids = np.asarray(fids)
    return {
        "point":    fid_from_features(gt_feat[:n], pred_feat[:n]),
        "mean":     float(fids.mean()),
        "median":   float(np.median(fids)),
        "ci_low":   float(np.quantile(fids, alpha / 2)),
        "ci_high":  float(np.quantile(fids, 1 - alpha / 2)),
        "n_pairs":  int(n),
        "n_resamples": int(len(fids)),
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Bootstrap CIs for FID")
    parser.add_argument("--dataset", choices=["nopscadlib", "abc", "slice100k"], required=True)
    parser.add_argument("--n-resamples", type=int, default=1000)
    parser.add_argument("--alpha", type=float, default=0.05)
    parser.add_argument(
        "--cache-dir", type=Path,
        help="Override the FID feature cache directory (default: metrics/<dataset>/fid/_cache)",
    )
    args = parser.parse_args()

    fid_dir = METRICS / args.dataset / "fid"
    cache_dir = args.cache_dir or (fid_dir / "_cache")
    if not cache_dir.exists():
        sys.exit(f"No FID feature cache found at {cache_dir}. Run compute_fid.py first.")

    features = load_features(cache_dir)
    if "gt" not in features:
        sys.exit(f"No 'gt_features.npz' in {cache_dir} — was compute_fid.py run with cache enabled?")

    gt_feat = features["gt"]
    rng = np.random.default_rng(42)
    out = {
        "dataset": args.dataset,
        "n_resamples": args.n_resamples,
        "alpha": args.alpha,
        "per_method": {},
    }
    for name, pred_feat in features.items():
        if name == "gt":
            continue
        log.info("method=%s, %d feature vectors", name, pred_feat.shape[0])
        out["per_method"][name] = bootstrap_one(gt_feat, pred_feat, args.n_resamples, args.alpha, rng)

    out_path = fid_dir / "ci.json"
    out_path.write_text(json.dumps(out, indent=2))
    log.info("wrote %s", out_path.relative_to(REPO_ROOT))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
