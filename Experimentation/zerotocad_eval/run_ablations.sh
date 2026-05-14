#!/usr/bin/env bash
# Phase 6 — run the four ablations enumerated in CRAFT_zerotocad_eval_plan.md §10.
#
# Each ablation toggles ONE knob and re-runs CRAFT v3 on the same benchmark.
# Sample-matched against the headline craft_v3 run so deltas are clean.
#
# Usage:
#   bash run_ablations.sh ztc_test 1000
#   bash run_ablations.sh abc_ood 1000
#
# Prerequisites:
#   - data/{benchmark}/{uuid}/ already populated
#   - results/zerotocad_eval/{benchmark}/craft_v3/ has the headline run

set -euo pipefail

BENCHMARK="${1:-ztc_test}"
LIMIT="${2:-1000}"

echo "===================================================="
echo " CRAFT v3 ablations — benchmark=$BENCHMARK n=$LIMIT"
echo "===================================================="

# --- 1) Disable v3 gap-refinement (the VLM correction step) ---------------
echo ""
echo "[1/4] Ablation: USE_VLM_CORRECTION=False (no gap refinement)"
USE_VLM_CORRECTION=False \
  python -m Experimentation.zerotocad_eval.run_eval \
    --phase ablation --benchmark "$BENCHMARK" \
    --methods craft_v3 --tag craft_v3_no_vlm --limit "$LIMIT" --score

# --- 2) Disable NopSCADlib KB retrieval -----------------------------------
echo ""
echo "[2/4] Ablation: KB disabled"
CRAFT_KB_DISABLE=1 \
  python -m Experimentation.zerotocad_eval.run_eval \
    --phase ablation --benchmark "$BENCHMARK" \
    --methods craft_v3 --tag craft_v3_no_kb --limit "$LIMIT" --score

# --- 3) Disable NURBS / smooth-surface modules ----------------------------
echo ""
echo "[3/4] Ablation: NURBS/smooth-surface modules disabled"
CRAFT_DISABLE_NURBS=1 \
  python -m Experimentation.zerotocad_eval.run_eval \
    --phase ablation --benchmark "$BENCHMARK" \
    --methods craft_v3 --tag craft_v3_no_nurbs --limit "$LIMIT" --score

# --- 4) Swap the LLM backbone (Gemini instead of GPT-5.2) -----------------
echo ""
echo "[4/4] Ablation: Gemini backbone (MODEL_REASONING=gemini-2.5-pro)"
MODEL_REASONING=gemini-2.5-pro \
  python -m Experimentation.zerotocad_eval.run_eval \
    --phase ablation --benchmark "$BENCHMARK" \
    --methods craft_v3 --tag craft_v3_gemini --limit "$LIMIT" --score

echo ""
echo "Done. Summary tables in results/zerotocad_eval/metrics/$BENCHMARK/"
ls -1 "results/zerotocad_eval/metrics/$BENCHMARK/" 2>/dev/null
