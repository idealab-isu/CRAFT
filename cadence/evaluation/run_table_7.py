#!/usr/bin/env python3
"""
Run Table 7: Verification Ablation

Before/after part presence for Essential/Secondary/Optional tiers

Usage:
    python run_table_7.py                # Full prompts
    python run_table_7.py --quick        # Quick test (6 prompts)
"""

import os
import sys
import json
import argparse
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from dotenv import load_dotenv
load_dotenv()


def main():
    parser = argparse.ArgumentParser(description="Table 7: Verification Ablation")
    parser.add_argument("--n", type=int, default=30, help="Number of prompts")
    parser.add_argument("--quick", action="store_true", help="Quick test (6 prompts)")
    parser.add_argument("--output", type=str, default="./evaluation_results/table7")
    parser.add_argument("--pipeline", type=str, default="gpt-4o")
    parser.add_argument("--vlm", type=str, default="gpt-5.2")

    args = parser.parse_args()

    if not os.getenv("OPENAI_API_KEY"):
        print("ERROR: OPENAI_API_KEY not set")
        sys.exit(1)

    n_prompts = 6 if args.quick else args.n

    from paper_test_prompts import get_prompts_for_table
    from paper_evaluation import PaperEvaluationRunner, generate_table_7_verification_ablation

    # Get prompts with tiered parts (secondary/optional)
    prompts = get_prompts_for_table(7)[:n_prompts]

    print(f"\n{'='*60}")
    print(f"TABLE 7: VERIFICATION ABLATION")
    print(f"{'='*60}")
    print(f"Prompts: {len(prompts)} (with tiered parts)")
    print(f"Comparing: Without vs With Component Verification")
    print(f"{'='*60}\n")

    # Run WITHOUT verification
    print("\n--- [1/2] WITHOUT Component Verification ---")
    runner_before = PaperEvaluationRunner(
        output_dir=f"{args.output}/without_verification",
        pipeline_model=args.pipeline,
        vlm_model=args.vlm,
        use_vlm_correction=True,
        use_verification=False
    )
    results_before = runner_before.run_evaluation(prompts)

    # Run WITH verification
    print("\n--- [2/2] WITH Component Verification ---")
    runner_after = PaperEvaluationRunner(
        output_dir=f"{args.output}/with_verification",
        pipeline_model=args.pipeline,
        vlm_model=args.vlm,
        use_vlm_correction=True,
        use_verification=True,
        max_verification_iterations=3
    )
    results_after = runner_after.run_evaluation(prompts)

    # Generate table
    metrics = generate_table_7_verification_ablation(results_before, results_after)

    output_dir = Path(args.output)
    output_dir.mkdir(parents=True, exist_ok=True)

    table_path = output_dir / "table_7_verification_ablation.json"
    with open(table_path, "w") as f:
        json.dump(metrics, f, indent=2)

    # Generate LaTeX
    latex = generate_latex_table_7(metrics)
    latex_path = output_dir / "table_7.tex"
    with open(latex_path, "w") as f:
        f.write(latex)

    # Print summary
    print(f"\n{'='*60}")
    print(f"TABLE 7: VERIFICATION ABLATION RESULTS")
    print(f"{'='*60}")
    print(f"{'Condition':<20} {'Essential%':>12} {'Secondary%':>12} {'Optional%':>12} {'Overall%':>12}")
    print("-" * 70)
    for key, m in metrics.items():
        print(f"{m['label']:<20} {m['essential_rate']:>11.1f}% {m['secondary_rate']:>11.1f}% "
              f"{m['optional_rate']:>11.1f}% {m['overall_parts_pct']:>11.1f}%")

    print(f"\nResults saved to: {output_dir}")
    print(f"LaTeX table: {latex_path}")


def generate_latex_table_7(metrics: dict) -> str:
    """Generate LaTeX table for Table 7."""
    before = metrics.get("before_verification", {})
    after = metrics.get("after_verification", {})

    return f"""\\begin{{table}}[h]
\\centering
\\caption{{Verification Ablation: Part Presence by Tier}}
\\label{{tab:verification-ablation}}
\\begin{{tabular}}{{lcccc}}
\\toprule
\\textbf{{Condition}} & \\textbf{{Essential \\%}} & \\textbf{{Secondary \\%}} & \\textbf{{Optional \\%}} & \\textbf{{Overall \\%}} \\\\
\\midrule
Before Verification & {before.get('essential_rate', 0):.1f} & {before.get('secondary_rate', 0):.1f} & {before.get('optional_rate', 0):.1f} & {before.get('overall_parts_pct', 0):.1f} \\\\
After Verification & \\textbf{{{after.get('essential_rate', 0):.1f}}} & \\textbf{{{after.get('secondary_rate', 0):.1f}}} & \\textbf{{{after.get('optional_rate', 0):.1f}}} & \\textbf{{{after.get('overall_parts_pct', 0):.1f}}} \\\\
\\bottomrule
\\end{{tabular}}
\\end{{table}}
"""


if __name__ == "__main__":
    main()
