"""
CRAFT v4 — GPT-5.2-baseline-first pipeline with non-regression gating.

Architecture:
    prompt
      → Stage 0: GPT-5.2 direct SCAD generation (parametric system prompt)
      → Stage 1: Render 8 views + STL
      → Stage 2: Deterministic sanity check (manifold, non-empty, view coverage)
      → Stage 3: Optional KB reference (high-confidence only, never essential_parts)
      → Stage 4: VLM gap assessment with acceptance criteria
      → Stage 5: Single targeted patch from baseline (no iterative drift)
      → Stage 6: Re-render patched output
      → Stage 7: Non-regression gate (keep patched only if criteria pass count
                 strictly increases AND no new render failures introduced)

Key invariant: v4 output quality >= GPT-5.2 baseline quality, on every sample,
in expectation. The gate decision uses ONLY inference-available signals
(acceptance-criteria delta, render validity). Ground-truth metrics are never
used at inference. A separate oracle ablation (run_v4_oracle_ablation.py)
replaces the gate with a ground-truth-CD selector to produce an upper-bound
figure for the paper.
"""

from .runner import V4Runner, V4Result, V4Config
from .baseline_generator import BaselineGenerator
from .render_check import RenderCheck, RenderArtifacts, SanityVerdict
from .kb_reference import KBReference
from .gap_assessor import GapAssessor, GapReport
from .patcher import SCADPatcher
from .regression_gate import RegressionGate, GateDecision

__all__ = [
    "V4Runner",
    "V4Result",
    "V4Config",
    "BaselineGenerator",
    "RenderCheck",
    "RenderArtifacts",
    "SanityVerdict",
    "KBReference",
    "GapAssessor",
    "GapReport",
    "SCADPatcher",
    "RegressionGate",
    "GateDecision",
]
