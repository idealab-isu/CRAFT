#!/usr/bin/env python3
"""
Quick test script for evaluation framework.

Run this to quickly verify the evaluation works with 3 prompts.

Usage:
    cd llm_to_cad/craft
    python -m evaluation.quick_test
"""

import os
import sys
from pathlib import Path

# Setup paths
sys.path.insert(0, str(Path(__file__).parent.parent))
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

os.chdir(Path(__file__).parent.parent)

from dotenv import load_dotenv
load_dotenv()


def quick_test():
    """Run quick evaluation test."""
    # Check API key
    if not os.getenv("OPENAI_API_KEY"):
        print("ERROR: Set OPENAI_API_KEY in environment or .env file")
        return

    print("="*60)
    print("CRAFT Quick Evaluation Test")
    print("="*60)

    # Import after path setup
    from evaluation.test_prompts import TEST_PROMPTS
    from evaluation.comparison import ComparisonRunner

    # Get 3 prompts (1 simple, 1 medium, 1 complex)
    test_prompts = [
        {"id": "test_simple", "text": "A cube with 30mm sides", "category": "simple"},
        {"id": "test_medium", "text": "A coffee mug with a handle", "category": "medium"},
        {"id": "test_complex", "text": "A gear with 8 teeth and 30mm diameter", "category": "complex"},
    ]

    print(f"\nTesting {len(test_prompts)} prompts...")

    # Run comparison
    # CRAFT uses gpt-5.2, Baseline uses GPT-4o
    runner = ComparisonRunner(
        output_dir="./quick_test_results",
        craft_model="gpt-5.2",
        baseline_model="gpt-4o",
        auto_repair=True
    )

    results, summary = runner.run_comparison(prompts=test_prompts)

    print("\n" + "="*60)
    print("QUICK TEST RESULTS")
    print("="*60)

    print("\nPer-Prompt Results:")
    for r in results:
        winner = "CRAFT" if r.craft_wins else ("Baseline" if r.baseline_wins else "Tie")
        print(f"  {r.prompt_id}: {winner}")
        print(f"    CRAFT:  syntax={r.craft_syntax_valid}, render={r.craft_render_success}, geometry={r.craft_has_geometry}")
        print(f"    Baseline: syntax={r.baseline_syntax_valid}, render={r.baseline_render_success}, geometry={r.baseline_has_geometry}")

    print(f"\nOverall: CRAFT {summary.craft_wins} wins, Baseline {summary.baseline_wins} wins, {summary.ties} ties")

    return results, summary


if __name__ == "__main__":
    quick_test()
