#!/usr/bin/env python3
"""
Run Table 4: Main Results

Metrics: Compile %, Render %, Val Score, Parts %, Human Eval
For each method × modality

Usage:
    python run_table_4.py                     # Full 30 prompts
    python run_table_4.py --quick             # Quick test (6 prompts)
    python run_table_4.py --n 15              # Custom count
    python run_table_4.py --pipeline gpt-4o   # Specify pipeline model
    python run_table_4.py --vlm gpt-5.2       # Specify VLM model
"""

import os
import sys
import json
import argparse
from pathlib import Path
from datetime import datetime

sys.path.insert(0, str(Path(__file__).parent.parent))
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from dotenv import load_dotenv
load_dotenv()


def main():
    parser = argparse.ArgumentParser(description="Table 4: Main Results")
    parser.add_argument("--n", type=int, default=30, help="Number of prompts")
    parser.add_argument("--quick", action="store_true", help="Quick test (6 prompts)")
    parser.add_argument("--output", type=str, default="./evaluation_results/table4",
                        help="Output directory")
    parser.add_argument("--pipeline", type=str, default="gpt-4o",
                        help="Pipeline model (default: gpt-4o)")
    parser.add_argument("--vlm", type=str, default="gpt-5.2",
                        help="VLM model (default: gpt-5.2)")
    parser.add_argument("--no-vlm", action="store_true",
                        help="Disable VLM correction")
    parser.add_argument("--no-verify", action="store_true",
                        help="Disable component verification")

    args = parser.parse_args()

    if not os.getenv("OPENAI_API_KEY"):
        print("ERROR: OPENAI_API_KEY not set")
        sys.exit(1)

    n_prompts = 6 if args.quick else args.n

    from paper_test_prompts import get_prompts_subset
    from paper_evaluation import PaperEvaluationRunner, generate_table_4_main_results

    prompts = get_prompts_subset(n_prompts, balanced=True)

    print(f"\n{'='*60}")
    print(f"TABLE 4: MAIN RESULTS")
    print(f"{'='*60}")
    print(f"Prompts: {len(prompts)}")
    print(f"Reasoning Model: {args.vlm} (understanding, planning, VLM, verification)")
    print(f"Compiler Model: {args.pipeline} (code generation)")
    print(f"VLM Correction: {not args.no_vlm}")
    print(f"Verification: {not args.no_verify}")
    print(f"{'='*60}\n")

    runner = PaperEvaluationRunner(
        output_dir=args.output,
        pipeline_model=args.pipeline,
        vlm_model=args.vlm,
        use_vlm_correction=not args.no_vlm,
        max_vlm_iterations=3,
        use_verification=not args.no_verify
    )

    results = runner.run_evaluation(prompts)
    metrics = generate_table_4_main_results(results)

    # Save metrics
    table_path = runner.run_dir / "table_4_main_results.json"
    with open(table_path, "w") as f:
        json.dump(metrics, f, indent=2)

    # Generate LaTeX
    latex = generate_latex_table_4(metrics)
    latex_path = runner.run_dir / "table_4.tex"
    with open(latex_path, "w") as f:
        f.write(latex)

    # Print summary
    print(f"\n{'='*60}")
    print(f"TABLE 4: MAIN RESULTS")
    print(f"{'='*60}")
    print(f"Total Prompts:      {metrics['n_prompts']}")
    print(f"Compile Rate:       {metrics['compile_rate']:.1f}%")
    print(f"Render Rate:        {metrics['render_rate']:.1f}%")
    print(f"Geometry Present:   {metrics['geometry_present_rate']:.1f}%")
    print(f"Validation Score:   {metrics['avg_validation_score']:.1f}")
    print(f"Validation Pass:    {metrics['validation_pass_rate']:.1f}%")
    print(f"VLM Approval:       {metrics['vlm_approval_rate']:.1f}%")
    print(f"Parts Percentage:   {metrics['avg_parts_percentage']:.1f}%")
    print(f"Avg VLM Fixes:      {metrics['avg_vlm_corrections']:.1f}")
    print(f"Avg Verif Fixes:    {metrics['avg_verif_corrections']:.1f}")
    print(f"Avg Code Length:    {metrics['avg_code_length']:.0f} chars")
    print(f"Avg Time:           {metrics['avg_time']:.1f}s")

    print(f"\n--- Per Category ---")
    for cat in ["simple", "medium", "complex"]:
        if f"{cat}_compile_rate" in metrics:
            print(f"{cat.capitalize():10s}: geometry={metrics.get(f'{cat}_geometry_rate', 0):.1f}%, "
                  f"val={metrics[f'{cat}_val_score']:.1f}, "
                  f"parts={metrics[f'{cat}_parts_pct']:.1f}%, "
                  f"vlm_fix={metrics.get(f'{cat}_vlm_corrections', 0):.1f}, "
                  f"code={metrics.get(f'{cat}_code_length', 0):.0f}ch")

    print(f"\nResults saved to: {runner.run_dir}")
    print(f"LaTeX table: {latex_path}")


def generate_latex_table_4(metrics: dict) -> str:
    """Generate LaTeX table for Table 4."""
    return f"""\\begin{{table}}[h]
\\centering
\\caption{{Main Results: CRAFT Performance on Text-to-CAD Generation}}
\\label{{tab:main-results}}
\\begin{{tabular}}{{lcccc}}
\\toprule
\\textbf{{Category}} & \\textbf{{Compile \\%}} & \\textbf{{Render \\%}} & \\textbf{{Val Score}} & \\textbf{{Parts \\%}} \\\\
\\midrule
Simple   & {metrics.get('simple_compile_rate', 0):.1f} & {metrics.get('simple_render_rate', 0):.1f} & {metrics.get('simple_val_score', 0):.1f} & {metrics.get('simple_parts_pct', 0):.1f} \\\\
Medium   & {metrics.get('medium_compile_rate', 0):.1f} & {metrics.get('medium_render_rate', 0):.1f} & {metrics.get('medium_val_score', 0):.1f} & {metrics.get('medium_parts_pct', 0):.1f} \\\\
Complex  & {metrics.get('complex_compile_rate', 0):.1f} & {metrics.get('complex_render_rate', 0):.1f} & {metrics.get('complex_val_score', 0):.1f} & {metrics.get('complex_parts_pct', 0):.1f} \\\\
\\midrule
\\textbf{{Overall}} & \\textbf{{{metrics['compile_rate']:.1f}}} & \\textbf{{{metrics['render_rate']:.1f}}} & \\textbf{{{metrics['avg_validation_score']:.1f}}} & \\textbf{{{metrics['avg_parts_percentage']:.1f}}} \\\\
\\bottomrule
\\end{{tabular}}
\\end{{table}}
"""


if __name__ == "__main__":
    main()
