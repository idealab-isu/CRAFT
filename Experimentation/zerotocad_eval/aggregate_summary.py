"""Aggregate per-method scoring JSONs into a single summary.md table.

Reads every `{method_tag}.json` written by score_method.py and produces:
  - results/zerotocad_eval/metrics/{benchmark}/summary.md   (paper-ready table)
  - results/zerotocad_eval/metrics/{benchmark}/summary.json (aggregate stats)
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Dict, List


_HERE = Path(__file__).resolve()
_REPO_ROOT = _HERE.parents[2]


def _fmt(x, spec=".3f") -> str:
    if isinstance(x, (int, float)):
        return format(x, spec)
    return "n/a"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--benchmark", required=True,
                        help="Benchmark name (used to find the per-method JSONs and write the summary).")
    parser.add_argument("--metrics-dir", default=None,
                        help="Override metrics dir (default: results/zerotocad_eval/metrics/{benchmark}/).")
    args = parser.parse_args()

    metrics_dir = Path(args.metrics_dir).resolve() if args.metrics_dir else (
        _REPO_ROOT / "results" / "zerotocad_eval" / "metrics" / args.benchmark
    )
    if not metrics_dir.exists():
        print(f"[aggregate] no metrics dir at {metrics_dir}")
        return 1

    method_jsons = sorted([p for p in metrics_dir.glob("*.json") if p.name != "summary.json"])
    if not method_jsons:
        print(f"[aggregate] no per-method JSONs in {metrics_dir}")
        return 1

    rows = []
    aggregate = {}
    for p in method_jsons:
        data = json.loads(p.read_text())
        aggregate[data["method"]] = data
        rows.append((data["method"], data))

    lines = [
        f"# Zero-to-CAD eval — {args.benchmark}",
        "",
        f"_Aggregated across {len(rows)} method(s)._",
        "",
        "| Method | n | Success | Mean IoU | Median IoU | P90 IoU | Mean CD | Mean Editability |",
        "|--------|---|---------|----------|------------|---------|---------|------------------|",
    ]

    for method, data in rows:
        n = data["n"]
        if n == 0:
            lines.append(f"| {method} | 0 | n/a | n/a | n/a | n/a | n/a | n/a |")
            continue
        sr = f"{data['success_rate'] * 100:.1f}%"
        iou = data["voxel_iou"]
        cd = data["cd"]
        edit = data["editability"]
        lines.append(
            f"| {method} | {n} | {sr} | "
            f"{_fmt(iou['mean'])} | {_fmt(iou['median'])} | {_fmt(iou['p90'])} | "
            f"{_fmt(cd['mean'], '.4f')} | {_fmt(edit['mean'])} |"
        )

    out_md = metrics_dir / "summary.md"
    out_md.write_text("\n".join(lines) + "\n")
    (metrics_dir / "summary.json").write_text(json.dumps(aggregate, indent=2))
    print(f"[aggregate] wrote {out_md}")
    print("\n".join(lines))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
