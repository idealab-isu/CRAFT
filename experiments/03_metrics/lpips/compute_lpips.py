#!/usr/bin/env python3
"""
LPIPS (Learned Perceptual Image Patch Similarity) computer.

Computes LPIPS distance between predicted PNG renders and ground-truth PNG
renders, per-sample (keyed by prompt_id) and aggregated (mean/std/median per
method, plus per-tier breakdown).

Reproduces the format of `metrics/<dataset>/lpips/lpips_detailed_results.json`,
`lpips_scores.csv`, `lpips_summaries.json`, and `lpips_comparison_table.md`,
which previously existed without a committed generator script.

Backbone: VGG (default, matches the published numbers); AlexNet available via
--backbone alex.

Usage:
  python experiments/03_metrics/lpips/compute_lpips.py \\
      --gt-png-dir ground_truth/nopscadlib/png \\
      --models craft=results/nopscadlib/craft/png \\
               gpt4o=results/nopscadlib/baselines/gpt4o/png \\
               gpt52=results/nopscadlib/baselines/gpt52/png \\
      --benchmark-json ground_truth/nopscadlib/benchmark_ground_truth.json \\
      --output-dir metrics/nopscadlib/lpips
"""
from __future__ import annotations

import argparse
import json
import logging
import os
import sys
import time
from collections import defaultdict
from dataclasses import asdict, dataclass, field
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Tuple

import numpy as np

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger("lpips")


@dataclass
class SampleResult:
    prompt_id: str
    method: str
    tier: str
    family: str
    lpips: Optional[float] = None
    success: bool = False
    error: Optional[str] = None


def load_benchmark_metadata(json_path: Path) -> Dict[str, Dict]:
    with json_path.open() as f:
        data = json.load(f)
    out: Dict[str, Dict] = {}
    for comp in data.get("components", []):
        out[comp["id"]] = {
            "tier": comp.get("tier", "unknown"),
            "family": comp.get("component_family", "unknown"),
        }
    return out


def discover_pairs(gt_dir: Path, pred_dir: Path) -> List[Tuple[str, Path, Path]]:
    """Find prompt IDs present in both gt_dir and pred_dir as <id>.png."""
    gt_files = {p.stem: p for p in gt_dir.glob("*.png")}
    pred_files = {p.stem: p for p in pred_dir.glob("*.png")}
    common = sorted(set(gt_files) & set(pred_files))
    return [(pid, gt_files[pid], pred_files[pid]) for pid in common]


def load_lpips_model(backbone: str):
    """Lazy-import lpips so the script's --help doesn't require torch."""
    import torch
    import lpips as lpips_pkg

    device = "cuda" if torch.cuda.is_available() else "cpu"
    log.info("loading LPIPS model: backbone=%s, device=%s", backbone, device)
    model = lpips_pkg.LPIPS(net=backbone).to(device).eval()
    return model, device


def to_tensor(path: Path, device, size: int = 256):
    """Read PNG → normalized [-1, 1] tensor of shape (1, 3, H, W)."""
    import torch
    from PIL import Image

    img = Image.open(path).convert("RGB").resize((size, size), Image.BICUBIC)
    arr = np.asarray(img, dtype=np.float32) / 255.0  # [H, W, 3], in [0, 1]
    arr = arr * 2.0 - 1.0                            # rescale to [-1, 1]
    tensor = torch.from_numpy(arr).permute(2, 0, 1).unsqueeze(0).to(device)  # (1, 3, H, W)
    return tensor


def compute_one(model, device, gt_path: Path, pred_path: Path) -> float:
    import torch
    with torch.no_grad():
        gt = to_tensor(gt_path, device)
        pr = to_tensor(pred_path, device)
        d = model(gt, pr)
    return float(d.detach().cpu().item())


def summarize(values: List[float]) -> Dict[str, float]:
    if not values:
        return {"n": 0, "mean": None, "std": None, "median": None, "min": None, "max": None}
    arr = np.asarray(values, dtype=np.float64)
    return {
        "n": int(arr.size),
        "mean": float(arr.mean()),
        "std": float(arr.std(ddof=1)) if arr.size > 1 else 0.0,
        "median": float(np.median(arr)),
        "min": float(arr.min()),
        "max": float(arr.max()),
    }


def emit_markdown(per_method: Dict[str, Dict], out_path: Path) -> None:
    lines = ["# LPIPS Comparison\n", "| Method | n | Mean ↓ | Std | Median |", "|---|---:|---:|---:|---:|"]
    for method, s in per_method.items():
        ov = s["overall"]
        lines.append(
            f"| {method} | {ov['n']} | "
            f"{ov['mean']:.4f} | {ov['std']:.4f} | {ov['median']:.4f} |"
        )
    lines.append("")
    lines.append("## By tier\n")
    lines.append("| Method | Tier | n | Mean ↓ | Std |")
    lines.append("|---|---|---:|---:|---:|")
    for method, s in per_method.items():
        for tier in ("Simple", "Medium", "Complex"):
            t = s["by_tier"].get(tier, {"n": 0, "mean": None, "std": None})
            if t["n"]:
                lines.append(f"| {method} | {tier} | {t['n']} | {t['mean']:.4f} | {t['std']:.4f} |")
    out_path.write_text("\n".join(lines) + "\n")


def main() -> int:
    parser = argparse.ArgumentParser(description="Compute LPIPS for one or more methods")
    parser.add_argument("--gt-png-dir", type=Path, required=True)
    parser.add_argument(
        "--models", nargs="+", required=True,
        help='List of name=path pairs, e.g. craft=results/nopscadlib/craft/png',
    )
    parser.add_argument("--benchmark-json", type=Path,
                        help="Optional benchmark metadata JSON for per-tier breakdown")
    parser.add_argument("--backbone", choices=["vgg", "alex"], default="vgg")
    parser.add_argument("--output-dir", type=Path, required=True)
    args = parser.parse_args()

    args.output_dir.mkdir(parents=True, exist_ok=True)
    metadata = load_benchmark_metadata(args.benchmark_json) if args.benchmark_json else {}

    model, device = load_lpips_model(args.backbone)

    all_samples: List[SampleResult] = []
    per_method_summary: Dict[str, Dict] = {}
    started = time.time()

    for spec in args.models:
        if "=" not in spec:
            sys.exit(f"--models entries must be name=path; got {spec!r}")
        method, pred_dir = spec.split("=", 1)
        pred_dir = Path(pred_dir)
        pairs = discover_pairs(args.gt_png_dir, pred_dir)
        log.info("method=%s matched %d (gt, pred) pairs", method, len(pairs))

        per_tier: Dict[str, List[float]] = defaultdict(list)
        overall_values: List[float] = []

        for pid, gt_path, pred_path in pairs:
            meta = metadata.get(pid, {"tier": "unknown", "family": "unknown"})
            sample = SampleResult(prompt_id=pid, method=method, tier=meta["tier"], family=meta["family"])
            try:
                sample.lpips = compute_one(model, device, gt_path, pred_path)
                sample.success = True
                overall_values.append(sample.lpips)
                per_tier[meta["tier"]].append(sample.lpips)
            except Exception as e:
                sample.error = str(e)
                log.warning("method=%s prompt=%s failed: %s", method, pid, e)
            all_samples.append(sample)

        per_method_summary[method] = {
            "overall": summarize(overall_values),
            "by_tier": {t: summarize(v) for t, v in per_tier.items()},
        }

    elapsed = time.time() - started

    # Persist outputs ------------------------------------------------------
    detailed_path = args.output_dir / "lpips_detailed_results.json"
    summary_path  = args.output_dir / "lpips_summaries.json"
    csv_path      = args.output_dir / "lpips_scores.csv"
    md_path       = args.output_dir / "lpips_comparison_table.md"

    detailed_path.write_text(json.dumps([asdict(s) for s in all_samples], indent=2))
    summary_path.write_text(json.dumps({
        "elapsed_seconds": elapsed,
        "backbone": args.backbone,
        "device": device,
        "methods": per_method_summary,
        "produced_at": datetime.now().isoformat(),
    }, indent=2))

    # Wide CSV: one row per prompt, one column per method
    methods = [s.split("=", 1)[0] for s in args.models]
    by_pid: Dict[str, Dict[str, float]] = defaultdict(dict)
    for s in all_samples:
        if s.success:
            by_pid[s.prompt_id][s.method] = s.lpips
    with csv_path.open("w") as f:
        f.write("prompt_id,tier," + ",".join(methods) + "\n")
        for pid in sorted(by_pid):
            row = by_pid[pid]
            tier = metadata.get(pid, {}).get("tier", "")
            f.write(f"{pid},{tier}," + ",".join(f"{row.get(m, '')}" for m in methods) + "\n")

    emit_markdown(per_method_summary, md_path)

    log.info("done in %.1fs; wrote %s, %s, %s, %s", elapsed, detailed_path, summary_path, csv_path, md_path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
