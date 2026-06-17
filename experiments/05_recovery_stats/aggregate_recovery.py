#!/usr/bin/env python3
"""
Aggregate per-stage recovery statistics from CRAFT benchmark runs.

Reads `results/<dataset>/craft/results.json` (and `ablations/<variant>/...`
when asked), pulls the per-item `recovery_budget` and iteration histories
that Phase 0b instrumented, and emits:

  metrics/<dataset>/recovery/per_layer_stats.json
  metrics/<dataset>/recovery/per_tier_pass_rates.json
  metrics/<dataset>/recovery/recovery_table.md

Usage:
  python experiments/05_recovery_stats/aggregate_recovery.py --dataset nopscadlib
  python experiments/05_recovery_stats/aggregate_recovery.py --dataset nopscadlib --method ablations/no_retrieval
"""
from __future__ import annotations

import argparse
import json
import logging
from collections import Counter, defaultdict
from pathlib import Path
from typing import Dict, List, Optional

SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parent.parent
METRICS = REPO_ROOT / "metrics"

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger("recovery_stats")


LAYERS = (
    "schema_repair", "scad_autofix", "vlm_correction",
    "component_verification", "manual_repair",
)
TIERS = ("essential", "secondary", "optional")


def load_results(path: Path) -> List[dict]:
    if not path.exists():
        raise SystemExit(f"missing {path}")
    data = json.loads(path.read_text())
    if isinstance(data, dict) and "results" in data:
        return data["results"]
    if isinstance(data, list):
        return data
    if isinstance(data, dict):
        # legacy: dict keyed by prompt_id
        return list(data.values())
    raise SystemExit(f"unexpected JSON shape in {path}")


def aggregate_per_layer(results: List[dict]) -> Dict[str, Dict]:
    n = len(results)
    triggered = Counter({l: 0 for l in LAYERS})
    retries_sum = Counter({l: 0 for l in LAYERS})
    succeeded = Counter({l: 0 for l in LAYERS})
    budget_used_sum = 0
    budget_used_count = 0

    for r in results:
        rb = r.get("recovery_budget")
        if not rb:
            continue
        budget_used_sum += rb.get("used", 0)
        budget_used_count += 1
        for layer in LAYERS:
            if rb.get("per_layer_triggered", {}).get(layer):
                triggered[layer] += 1
            retries_sum[layer] += rb.get("per_layer_used", {}).get(layer, 0)
            if rb.get("per_layer_succeeded", {}).get(layer):
                succeeded[layer] += 1

    out: Dict[str, Dict] = {}
    for layer in LAYERS:
        tn = triggered[layer]
        out[layer] = {
            "trigger_rate":               (tn / n) if n else 0.0,
            "n_triggered":                tn,
            "mean_retries":               (retries_sum[layer] / tn) if tn else 0.0,
            "mean_retries_overall":       (retries_sum[layer] / n) if n else 0.0,
            "post_recovery_success_rate": (succeeded[layer] / tn) if tn else 0.0,
            "n_succeeded":                succeeded[layer],
        }

    out["__overall__"] = {
        "n_runs": n,
        "mean_budget_used": (budget_used_sum / budget_used_count) if budget_used_count else 0.0,
        "n_runs_with_budget_data": budget_used_count,
    }
    return out


def aggregate_per_tier_pass(results: List[dict]) -> Dict[str, Dict]:
    """For Layer 4 (component verification): pass rate of essential/secondary/optional parts."""
    seen = {t: 0 for t in TIERS}
    passed = {t: 0 for t in TIERS}
    for r in results:
        # final iteration's parts_present holds the post-recovery state
        history = r.get("component_iteration_history") or []
        if not history:
            continue
        final = history[-1]
        for p in final.get("parts_present", []):
            tier = p.get("tier", "secondary")
            if tier not in TIERS:
                continue
            seen[tier] += 1
            if p.get("meets_threshold"):
                passed[tier] += 1
    return {t: {"n": seen[t], "pass_rate": (passed[t] / seen[t]) if seen[t] else 0.0,
                "n_passed": passed[t]} for t in TIERS}


def emit_markdown(per_layer: Dict, per_tier: Dict, out_path: Path) -> None:
    lines = ["# Per-Stage Recovery Statistics\n",
             "## Per layer\n",
             "| Layer | Trigger rate | Mean retries (when triggered) | Post-recovery success |",
             "|---|---:|---:|---:|"]
    for layer in LAYERS:
        s = per_layer[layer]
        lines.append(
            f"| {layer.replace('_', ' ')} | "
            f"{s['trigger_rate']:.3f} | "
            f"{s['mean_retries']:.2f} | "
            f"{s['post_recovery_success_rate']:.3f} |"
        )
    overall = per_layer["__overall__"]
    lines.append("")
    lines.append(f"**Mean budget used:** {overall['mean_budget_used']:.2f} of "
                 f"10 attempts ({overall['n_runs_with_budget_data']}/{overall['n_runs']} runs reported budget telemetry).\n")
    lines.append("## Component verification, per-tier pass rates\n")
    lines.append("| Tier | Threshold | n parts | Pass rate |")
    lines.append("|---|---|---:|---:|")
    thresholds = {"essential": "85%", "secondary": "65%", "optional": "50%"}
    for t in TIERS:
        s = per_tier[t]
        lines.append(f"| {t.title()} | {thresholds[t]} | {s['n']} | {s['pass_rate']:.3f} |")
    out_path.write_text("\n".join(lines) + "\n")


def main() -> int:
    parser = argparse.ArgumentParser(description="Aggregate per-stage recovery statistics")
    parser.add_argument("--dataset", choices=["nopscadlib", "abc", "slice100k"], required=True)
    parser.add_argument(
        "--method", default="craft",
        help="Method subdir under results/<dataset>/ (default: craft). "
             "Use 'ablations/<variant>' or 'matched_effort/<variant>' for other runs.",
    )
    parser.add_argument(
        "--output-dir", type=Path,
        help="Override output dir (default: metrics/<dataset>/recovery)",
    )
    args = parser.parse_args()

    results_path = REPO_ROOT / "results" / args.dataset / args.method / "results.json"
    results = load_results(results_path)
    log.info("loaded %d results from %s", len(results), results_path.relative_to(REPO_ROOT))

    out_dir = args.output_dir or (METRICS / args.dataset / "recovery")
    out_dir.mkdir(parents=True, exist_ok=True)

    per_layer = aggregate_per_layer(results)
    per_tier = aggregate_per_tier_pass(results)

    (out_dir / "per_layer_stats.json").write_text(json.dumps(per_layer, indent=2))
    (out_dir / "per_tier_pass_rates.json").write_text(json.dumps(per_tier, indent=2))
    emit_markdown(per_layer, per_tier, out_dir / "recovery_table.md")

    log.info("wrote %s", out_dir.relative_to(REPO_ROOT))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
