#!/usr/bin/env python3
"""
CRAFT Evaluation Runner

Run this script to compare CRAFT (gpt-5.2) vs GPT-4o baseline.

Usage:
    python run_evaluation.py                        # Run with 15 prompts
    python run_evaluation.py --prompts 25           # Run with 25 prompts
    python run_evaluation.py --craft-model gpt-5.2  # Specify CRAFT model
    python run_evaluation.py --baseline-model gpt-4o  # Specify baseline model
    python run_evaluation.py --quick                # Quick test with 5 prompts
    python run_evaluation.py --baseline-only        # Run only baseline
    python run_evaluation.py --craft-only         # Run only CRAFT
"""

import os
import sys
import json
import argparse
from pathlib import Path
from datetime import datetime

# Add parent paths
sys.path.insert(0, str(Path(__file__).parent.parent))
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from dotenv import load_dotenv
load_dotenv()


def main():
    parser = argparse.ArgumentParser(description="CRAFT Evaluation Runner")
    parser.add_argument("--prompts", type=int, default=15,
                        help="Number of prompts to evaluate")
    parser.add_argument("--craft-model", type=str, default="gpt-5.2",
                        help="Model for CRAFT pipeline (default: gpt-5.2)")
    parser.add_argument("--baseline-model", type=str, default="gpt-4o",
                        help="Model for baseline (default: gpt-4o)")
    parser.add_argument("--output", type=str, default="./evaluation_results",
                        help="Output directory")
    parser.add_argument("--quick", action="store_true",
                        help="Quick test with 5 prompts")
    parser.add_argument("--baseline-only", action="store_true",
                        help="Run only baseline evaluation")
    parser.add_argument("--craft-only", action="store_true",
                        help="Run only CRAFT evaluation")
    parser.add_argument("--no-repair", action="store_true",
                        help="Disable auto-repair")
    parser.add_argument("--category", type=str, default=None,
                        help="Run specific category (simple, medium, complex, with_dimensions, mechanical)")

    args = parser.parse_args()

    # Quick mode
    if args.quick:
        args.prompts = 5

    # Check for API key
    if not os.getenv("OPENAI_API_KEY"):
        print("ERROR: OPENAI_API_KEY not set")
        print("Please set it in .env file or environment")
        sys.exit(1)

    # Create output directory with timestamp
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    output_dir = Path(args.output) / timestamp
    output_dir.mkdir(parents=True, exist_ok=True)

    print(f"\n{'='*60}")
    print("CRAFT Evaluation")
    print(f"{'='*60}")
    print(f"Output: {output_dir}")
    print(f"CRAFT Model: {args.craft_model}")
    print(f"Baseline Model: {args.baseline_model}")
    print(f"Prompts: {args.prompts}")
    print(f"Auto-repair: {not args.no_repair}")
    print(f"{'='*60}\n")

    # Import after path setup
    from evaluation.test_prompts import get_prompts_subset, get_prompts_by_category, get_all_prompts

    # Get prompts
    if args.category:
        prompts = get_prompts_by_category(args.category)
        prompts = [{"id": p["id"], "text": p["text"], "category": args.category} for p in prompts]
    else:
        prompts = get_prompts_subset(args.prompts)

    if not prompts:
        print("ERROR: No prompts found")
        sys.exit(1)

    print(f"Testing {len(prompts)} prompts\n")

    # Run evaluation
    if args.baseline_only:
        # Run only baseline (GPT-4o direct generation)
        from evaluation.baseline_gpt4o import GPT4oBaseline

        print(f"Running baseline only ({args.baseline_model})...")
        baseline = GPT4oBaseline(
            model=args.baseline_model,
            output_dir=str(output_dir / "baseline")
        )

        results = baseline.run_batch([
            {"id": p["id"], "text": p["text"]}
            for p in prompts
        ])

        # Print summary
        n = len(results)
        syntax_rate = sum(r.syntax_valid for r in results) / n
        render_rate = sum(r.render_success for r in results) / n
        geometry_rate = sum(r.has_geometry for r in results) / n

        print(f"\n{'='*60}")
        print(f"BASELINE RESULTS ({args.baseline_model})")
        print(f"{'='*60}")
        print(f"Syntax Pass: {syntax_rate:.1%}")
        print(f"Render Success: {render_rate:.1%}")
        print(f"Geometry Present: {geometry_rate:.1%}")

    elif args.craft_only:
        # Run only CRAFT (full pipeline)
        from evaluation.comparison import ComparisonRunner

        print(f"Running CRAFT only ({args.craft_model})...")
        runner = ComparisonRunner(
            output_dir=str(output_dir),
            craft_model=args.craft_model,
            baseline_model=args.baseline_model,
            auto_repair=not args.no_repair
        )

        results = []
        for prompt in prompts:
            result = runner.run_craft(prompt["id"], prompt["text"])
            results.append(result)
            print(f"  {prompt['id']}: syntax={result.syntax_valid}, render={result.render_success}")

        # Save results
        results_path = output_dir / "craft_results.json"
        with open(results_path, "w") as f:
            json.dump([r.to_dict() for r in results], f, indent=2)

        # Print summary
        n = len(results)
        syntax_rate = sum(r.syntax_valid for r in results) / n
        render_rate = sum(r.render_success for r in results) / n
        validation_rate = sum(r.validation_passed for r in results) / n
        geometry_rate = sum(r.has_geometry for r in results) / n

        print(f"\n{'='*60}")
        print(f"craft RESULTS ({args.craft_model})")
        print(f"{'='*60}")
        print(f"Syntax Pass: {syntax_rate:.1%}")
        print(f"Render Success: {render_rate:.1%}")
        print(f"Validation Pass: {validation_rate:.1%}")
        print(f"Geometry Present: {geometry_rate:.1%}")

    else:
        # Run full comparison: CRAFT (gpt-5.2) vs Baseline (GPT-4o)
        from evaluation.comparison import ComparisonRunner

        runner = ComparisonRunner(
            output_dir=str(output_dir),
            craft_model=args.craft_model,
            baseline_model=args.baseline_model,
            auto_repair=not args.no_repair
        )

        results, summary = runner.run_comparison(prompts=prompts)

        # Generate LaTeX table
        generate_latex_table(summary, output_dir)

    print(f"\nResults saved to: {output_dir}")


def generate_latex_table(summary, output_dir: Path):
    """Generate LaTeX table from summary."""
    latex = r"""
\begin{table}[h]
\centering
\caption{Quantitative Comparison: CRAFT vs Direct GPT-4o Baseline}
\label{tab:comparison}
\begin{tabular}{lcc}
\hline
\textbf{Metric} & \textbf{Direct GPT-4o} & \textbf{CRAFT (Ours)} \\
\hline
Syntax Pass Rate & """ + f"{summary.baseline_syntax_rate:.1%}" + r""" & \textbf{""" + f"{summary.craft_syntax_rate:.1%}" + r"""} \\
Render Success & """ + f"{summary.baseline_render_rate:.1%}" + r""" & \textbf{""" + f"{summary.craft_render_rate:.1%}" + r"""} \\
Geometry Present & """ + f"{summary.baseline_geometry_rate:.1%}" + r""" & \textbf{""" + f"{summary.craft_geometry_rate:.1%}" + r"""} \\
Validation Pass & N/A & """ + f"{summary.craft_validation_rate:.1%}" + r""" \\
Avg. Generation Time & """ + f"{summary.baseline_avg_time:.1f}s" + r""" & """ + f"{summary.craft_avg_time:.1f}s" + r""" \\
Avg. Attempts & 1.0 & """ + f"{summary.craft_avg_plan_attempts:.1f}" + r""" \\
\hline
\textbf{Head-to-Head Wins} & """ + str(summary.baseline_wins) + r""" & \textbf{""" + str(summary.craft_wins) + r"""} \\
\hline
\end{tabular}
\end{table}
"""

    # Save LaTeX
    latex_path = output_dir / "comparison_table.tex"
    with open(latex_path, "w") as f:
        f.write(latex)

    print(f"\nLaTeX table saved to: {latex_path}")


if __name__ == "__main__":
    main()
