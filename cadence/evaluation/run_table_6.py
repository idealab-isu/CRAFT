#!/usr/bin/env python3
"""
Run Table 6: VLM Iteration Ablation

Performance at 0, 1, 2, 3 VLM iterations + time cost

Usage:
    python run_table_6.py                # Full 30 prompts
    python run_table_6.py --quick        # Quick test (6 prompts)
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
    parser = argparse.ArgumentParser(description="Table 6: VLM Iteration Ablation")
    parser.add_argument("--n", type=int, default=30, help="Number of prompts")
    parser.add_argument("--quick", action="store_true", help="Quick test (6 prompts)")
    parser.add_argument("--output", type=str, default="./evaluation_results/table6")
    parser.add_argument("--pipeline", type=str, default="gpt-4o")
    parser.add_argument("--vlm", type=str, default="gpt-5.2")

    args = parser.parse_args()

    if not os.getenv("OPENAI_API_KEY"):
        print("ERROR: OPENAI_API_KEY not set")
        sys.exit(1)

    n_prompts = 6 if args.quick else args.n

    from paper_test_prompts import get_prompts_subset
    from paper_evaluation import PaperEvaluationRunner, generate_table_6_vlm_ablation

    prompts = get_prompts_subset(n_prompts, balanced=True)

    print(f"\n{'='*60}")
    print(f"TABLE 6: VLM ITERATION ABLATION")
    print(f"{'='*60}")
    print(f"Prompts: {len(prompts)}")
    print(f"Testing iterations: 0, 1, 2, 3")
    print(f"{'='*60}\n")

    results_by_iter = {}

    for max_iter in [0, 1, 2, 3]:
        print(f"\n--- [{max_iter+1}/4] Max VLM Iterations = {max_iter} ---")

        runner = PaperEvaluationRunner(
            output_dir=f"{args.output}/iter_{max_iter}",
            pipeline_model=args.pipeline,
            vlm_model=args.vlm,
            use_vlm_correction=(max_iter > 0),
            max_vlm_iterations=max_iter,
            use_verification=False  # Isolate VLM effect
        )

        results_by_iter[max_iter] = runner.run_evaluation(prompts)

    # Generate table
    metrics = generate_table_6_vlm_ablation(results_by_iter)

    output_dir = Path(args.output)
    output_dir.mkdir(parents=True, exist_ok=True)

    table_path = output_dir / "table_6_vlm_ablation.json"
    with open(table_path, "w") as f:
        json.dump(metrics, f, indent=2)

    # Generate LaTeX
    latex = generate_latex_table_6(metrics)
    latex_path = output_dir / "table_6.tex"
    with open(latex_path, "w") as f:
        f.write(latex)

    # Print summary
    print(f"\n{'='*60}")
    print(f"TABLE 6: VLM ITERATION ABLATION RESULTS")
    print(f"{'='*60}")
    print(f"{'Iterations':<12} {'Render%':>10} {'Approval%':>12} {'Confidence':>12} {'Time':>10}")
    print("-" * 60)
    for key, m in sorted(metrics.items()):
        print(f"{m['vlm_iterations']:<12} {m['render_rate']:>9.1f}% {m['vlm_approval_rate']:>11.1f}% "
              f"{m['avg_confidence']:>11.2f} {m['avg_time']:>9.1f}s")

    print(f"\nResults saved to: {output_dir}")
    print(f"LaTeX table: {latex_path}")


def generate_latex_table_6(metrics: dict) -> str:
    """Generate LaTeX table for Table 6."""
    rows = []
    for key in sorted(metrics.keys()):
        m = metrics[key]
        rows.append(f"{m['vlm_iterations']} & {m['render_rate']:.1f} & {m['vlm_approval_rate']:.1f} & "
                   f"{m['avg_confidence']:.2f} & {m['avg_time']:.1f} & {m['avg_vlm_time']:.1f}")

    return f"""\\begin{{table}}[h]
\\centering
\\caption{{VLM Iteration Ablation: Performance vs Iteration Count}}
\\label{{tab:vlm-ablation}}
\\begin{{tabular}}{{cccccc}}
\\toprule
\\textbf{{Max Iter}} & \\textbf{{Render \\%}} & \\textbf{{Approval \\%}} & \\textbf{{Confidence}} & \\textbf{{Total (s)}} & \\textbf{{VLM (s)}} \\\\
\\midrule
{' \\\\\n'.join(rows)} \\\\
\\bottomrule
\\end{{tabular}}
\\end{{table}}
"""


if __name__ == "__main__":
    main()
