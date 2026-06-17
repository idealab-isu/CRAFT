#!/usr/bin/env python3
"""
Paired Wilcoxon signed-rank tests (with Benjamini–Hochberg FDR correction)
for every CRAFT-vs-baseline comparison on every metric with per-sample data.

For each (metric, comparison) pair, prompts where BOTH methods produced a
value are paired by `prompt_id`. Output is one row per
(dataset, metric, reference, comparison).

Usage:
  python experiments/04_statistics/paired_tests.py --dataset nopscadlib
  python experiments/04_statistics/paired_tests.py --dataset nopscadlib --reference craft
"""
from __future__ import annotations

import argparse
import json
import logging
import sys
from collections import defaultdict
from pathlib import Path
from typing import Dict, List, Optional, Tuple

import numpy as np

SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parent.parent
METRICS = REPO_ROOT / "metrics"

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger("paired")

# ONLY metrics that appear in the paper. HD/NC/LPIPS deliberately excluded.
SOURCES = [
    ("detailed_results.json", [
        "chamfer_distance", "f1_score_1pct", "f1_score_5pct", "voxel_iou",
    ]),
    ("clip/clip_detailed_results.json", ["clip_score"]),
]


def normalize_records(raw) -> List[dict]:
    """Same normalizer as bootstrap_ci: accept flat list OR {method: [records]}."""
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


try:
    from scipy.stats import wilcoxon as _scipy_wilcoxon
    _HAVE_SCIPY = True
except ImportError:  # pragma: no cover
    _scipy_wilcoxon = None
    _HAVE_SCIPY = False


def wilcoxon(deltas: np.ndarray) -> Optional[Tuple[float, float]]:
    """
    Wilcoxon signed-rank test on the array of deltas (b-a).
    Returns (statistic, two-sided p-value), or None when the sample is too small.
    """
    if not _HAVE_SCIPY:
        return None
    if deltas.size < 6:
        return None
    deltas = deltas[deltas != 0]  # drop exact ties
    if deltas.size < 6:
        return None
    res = _scipy_wilcoxon(deltas, alternative="two-sided", zero_method="wilcox", correction=False)
    return float(res.statistic), float(res.pvalue)


def benjamini_hochberg(pvalues: List[float], alpha: float = 0.05) -> List[float]:
    """Return BH-adjusted p-values (same order as input)."""
    p = np.asarray(pvalues, dtype=np.float64)
    n = p.size
    order = np.argsort(p)
    ranked = p[order]
    adj = np.minimum.accumulate((ranked * n / (np.arange(n) + 1))[::-1])[::-1]
    adj = np.clip(adj, 0.0, 1.0)
    out = np.empty_like(p)
    out[order] = adj
    return out.tolist()


def load_records(detail_path: Path) -> List[dict]:
    if not detail_path.exists():
        return []
    return normalize_records(json.loads(detail_path.read_text()))


def pair_values(
    records: List[dict], reference: str, comparison: str, field_name: str,
) -> Tuple[np.ndarray, np.ndarray]:
    """Return paired arrays (ref_values, cmp_values), aligned by prompt_id."""
    ref: Dict[str, float] = {}
    cmp: Dict[str, float] = {}
    for r in records:
        if not r.get("success", True):
            continue
        m = r["method"]
        v = r.get(field_name)
        if v is None:
            continue
        if isinstance(v, float) and (v != v):  # drop NaN
            continue
        if m == reference:
            ref[r["prompt_id"]] = v
        elif m == comparison:
            cmp[r["prompt_id"]] = v
    common = sorted(set(ref) & set(cmp))
    return np.asarray([ref[p] for p in common]), np.asarray([cmp[p] for p in common])


def main() -> int:
    parser = argparse.ArgumentParser(description="Paired Wilcoxon tests with FDR correction")
    parser.add_argument("--dataset", choices=["nopscadlib", "abc", "slice100k"], required=True)
    parser.add_argument("--reference", default="craft",
                        help="The reference method (default: craft).")
    parser.add_argument("--comparisons", nargs="+",
                        help="Methods to compare against the reference (default: every other method present)")
    parser.add_argument("--alpha", type=float, default=0.05)
    args = parser.parse_args()

    if not _HAVE_SCIPY:
        sys.exit("ERROR: scipy is required for the Wilcoxon test. Install with: pip install scipy")

    dataset_dir = METRICS / args.dataset
    methods_seen = set()

    # First pass: collect methods present anywhere
    sources_with_records: List[Tuple[str, List[str], List[dict]]] = []
    for rel_path, fields in SOURCES:
        records = load_records(dataset_dir / rel_path)
        if not records:
            continue
        for r in records:
            if r.get("method"):
                methods_seen.add(r["method"])
        sources_with_records.append((rel_path, fields, records))

    methods_seen.discard(args.reference)
    comparisons = args.comparisons or sorted(methods_seen)
    log.info("dataset=%s reference=%s comparisons=%s", args.dataset, args.reference, comparisons)

    raw_rows = []
    raw_pvals: List[float] = []
    for rel_path, fields, records in sources_with_records:
        for field_name in fields:
            for cmp_method in comparisons:
                ref_vals, cmp_vals = pair_values(records, args.reference, cmp_method, field_name)
                if ref_vals.size < 6:
                    continue
                deltas = cmp_vals - ref_vals
                result = wilcoxon(deltas)
                if result is None:
                    continue
                stat, p = result
                row = {
                    "dataset": args.dataset,
                    "metric_source": rel_path,
                    "metric": field_name,
                    "reference": args.reference,
                    "comparison": cmp_method,
                    "n_pairs": int(ref_vals.size),
                    "median_delta": float(np.median(deltas)),
                    "wilcoxon_statistic": stat,
                    "p_value": p,
                }
                raw_rows.append(row)
                raw_pvals.append(p)

    # FDR correction across the whole family
    adj = benjamini_hochberg(raw_pvals, alpha=args.alpha) if raw_pvals else []
    for row, p_adj in zip(raw_rows, adj):
        row["p_value_adj"] = float(p_adj)
        row["significant"] = bool(p_adj < args.alpha)

    out_path = dataset_dir / "paired_tests.json"
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(json.dumps({
        "dataset": args.dataset,
        "reference": args.reference,
        "alpha": args.alpha,
        "correction": "benjamini_hochberg",
        "tests": raw_rows,
    }, indent=2))
    log.info("wrote %s (%d tests)", out_path.relative_to(REPO_ROOT), len(raw_rows))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
