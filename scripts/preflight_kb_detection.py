#!/usr/bin/env python3
"""
Pre-flight: how many of the 468 NopSCADlib benchmark prompts trigger KB detection?
Runs the SAME detector the reasoner uses, over the SAME prompt field run_craft.py feeds it.
No API, no rendering — finishes in seconds. Run BEFORE the full re-run:
    python scripts/preflight_kb_detection.py
"""
import sys, json
from pathlib import Path
from collections import Counter

REPO = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(REPO / "pipeline"))

from kb.detector import ComponentDetector

gt = json.loads((REPO / "ground_truth" / "nopscadlib" / "benchmark_ground_truth.json").read_text())
comps = gt["components"]

det = ComponentDetector()
det.load_components()

hit = 0
by_tier = Counter()
tot_tier = Counter()
misses = []
sample_hits = []

for c in comps:
    pid, prompt, tier = c["id"], c["prompt"], c.get("tier", "?")
    tot_tier[tier] += 1
    r = det.detect(prompt)
    if getattr(r, "has_kb_components", False):
        hit += 1
        by_tier[tier] += 1
        if len(sample_hits) < 8:
            names = [getattr(x, "name", getattr(x, "component_id", "?")) for x in r.detected_components[:2]]
            sample_hits.append((pid, names))
    elif len(misses) < 20:
        misses.append((pid, prompt[:75]))

n = len(comps)
print("=" * 64)
print(f"KB DETECTION over {n} benchmark prompts:  {hit}/{n} = {hit/n:.1%}")
print("=" * 64)
for t in ["Simple", "Medium", "Complex"]:
    if tot_tier[t]:
        print(f"  {t:8} {by_tier[t]:3}/{tot_tier[t]:3} = {by_tier[t]/tot_tier[t]:.1%}")
print("\nSample detections (prompt id -> matched components):")
for pid, names in sample_hits:
    print(f"  ✓ {pid:32} -> {names}")
print("\nSample non-detections (check these are genuinely generic shapes, not missed components):")
for pid, pr in misses:
    print(f"  - {pid:32} {pr}")
print("\nIf the rate is high (most component-named prompts hit), you're clear to re-run run_craft.py.")
