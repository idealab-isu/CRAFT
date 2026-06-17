#!/usr/bin/env python3
"""
Run Table 8: Single Image Performance by Complexity

By category (Simple/Medium/Complex): Render %, Parts %, SSIM

Usage:
    python run_table_8.py                # Full 30 prompts
    python run_table_8.py --quick        # Quick test (6 prompts)
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
    parser = argparse.ArgumentParser(description="Table 8: Single Image by Complexity")
    parser.add_argument("--n", type=int, default=30, help="Number of prompts")
    parser.add_argument("--quick", action="store_true", help="Quick test (6 prompts)")
    parser.add_argument("--output", type=str, default="./evaluation_results/table8")
    parser.add_argument("--pipeline", type=str, default="gpt-4o")
    parser.add_argument("--vlm", type=str, default="gpt-5.2")

    args = parser.parse_args()

    if not os.getenv("OPENAI_API_KEY"):
        print("ERROR: OPENAI_API_KEY not set")
        sys.exit(1)

    n_prompts = 6 if args.quick else args.n

    from paper_test_prompts import get_all_prompts
    from paper_evaluation import PaperEvaluationRunner, generate_table_8_single_image_performance

    prompts = get_all_prompts()[:n_prompts]

    print(f"\n{'='*60}")
    print(f"TABLE 8: SINGLE IMAGE PERFORMANCE BY COMPLEXITY")
    print(f"{'='*60}")
    print(f"Prompts: {len(prompts)}")
    print(f"Categories: Simple, Medium, Complex")
    print(f"{'='*60}\n")

    runner = PaperEvaluationRunner(
        output_dir=args.output,
        pipeline_model=args.pipeline,
        vlm_model=args.vlm,
        use_vlm_correction=True,
        use_verification=True
    )

    results = runner.run_evaluation(prompts)
    metrics = generate_table_8_single_image_performance(results)

    # Save
    table_path = runner.run_dir / "table_8_complexity.json"
    with open(table_path, "w") as f:
        json.dump(metrics, f, indent=2)

    # Generate LaTeX
    latex = generate_latex_table_8(metrics)
    latex_path = runner.run_dir / "table_8.tex"
    with open(latex_path, "w") as f:
        f.write(latex)

    # Print summary
    print(f"\n{'='*60}")
    print(f"TABLE 8: SINGLE IMAGE BY COMPLEXITY RESULTS")
    print(f"{'='*60}")
    print(f"{'Category':<12} {'N':>5} {'Render%':>10} {'Parts%':>10} {'Val':>8} {'Time':>10}")
    print("-" * 60)
    for cat in ["simple", "medium", "complex"]:
        if cat in metrics:
            m = metrics[cat]
            print(f"{m['category'].capitalize():<12} {m['n_prompts']:>5} {m['render_rate']:>9.1f}% "
                  f"{m['parts_pct']:>9.1f}% {m['val_score']:>7.1f} {m['avg_time']:>9.1f}s")

    print(f"\nResults saved to: {runner.run_dir}")
    print(f"LaTeX table: {latex_path}")


def generate_latex_table_8(metrics: dict) -> str:
    """Generate LaTeX table for Table 8."""
    rows = []
    for cat in ["simple", "medium", "complex"]:
        if cat in metrics:
            m = metrics[cat]
            rows.append(f"{cat.capitalize()} & {m['n_prompts']} & {m['render_rate']:.1f} & "
                       f"{m['parts_pct']:.1f} & {m['val_score']:.1f} & {m['avg_time']:.1f}")

    return f"""\\begin{{table}}[h]
\\centering
\\caption{{Single Image Performance by Complexity Category}}
\\label{{tab:complexity}}
\\begin{{tabular}}{{lccccc}}
\\toprule
\\textbf{{Category}} & \\textbf{{N}} & \\textbf{{Render \\%}} & \\textbf{{Parts \\%}} & \\textbf{{Val Score}} & \\textbf{{Time (s)}} \\\\
\\midrule
{' \\\\\n'.join(rows)} \\\\
\\bottomrule
\\end{{tabular}}
\\end{{table}}
"""


if __name__ == "__main__":
    main()
