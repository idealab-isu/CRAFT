#!/usr/bin/env python3
"""
Run Table 5: Model Ablation

Compare: All-GPT4o vs All-GPT5.2 vs Hybrid (GPT-4o pipeline + GPT-5.2 VLM)

Usage:
    python run_table_5.py                # Full 30 prompts
    python run_table_5.py --quick        # Quick test (6 prompts)
    python run_table_5.py --n 15         # Custom count
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
    parser = argparse.ArgumentParser(description="Table 5: Model Ablation")
    parser.add_argument("--n", type=int, default=30, help="Number of prompts")
    parser.add_argument("--quick", action="store_true", help="Quick test (6 prompts)")
    parser.add_argument("--output", type=str, default="./evaluation_results/table5")

    args = parser.parse_args()

    if not os.getenv("OPENAI_API_KEY"):
        print("ERROR: OPENAI_API_KEY not set")
        sys.exit(1)

    n_prompts = 6 if args.quick else args.n

    from paper_test_prompts import get_prompts_subset
    from paper_evaluation import PaperEvaluationRunner, generate_table_5_model_ablation

    prompts = get_prompts_subset(n_prompts, balanced=True)

    print(f"\n{'='*60}")
    print(f"TABLE 5: MODEL ABLATION")
    print(f"{'='*60}")
    print(f"Prompts: {len(prompts)}")
    print(f"Comparing: All-GPT4o vs All-GPT5.2 vs Hybrid")
    print(f"{'='*60}\n")

    results_all = {}

    # Configuration 1: All GPT-4o
    print("\n--- [1/3] All-GPT4o ---")
    runner1 = PaperEvaluationRunner(
        output_dir=f"{args.output}/all_gpt4o",
        pipeline_model="gpt-4o",
        vlm_model="gpt-4o",
        use_vlm_correction=True,
        use_verification=True
    )
    results_all["gpt4o"] = runner1.run_evaluation(prompts)

    # Configuration 2: All GPT-5.2
    print("\n--- [2/3] All-GPT5.2 ---")
    runner2 = PaperEvaluationRunner(
        output_dir=f"{args.output}/all_gpt52",
        pipeline_model="gpt-5.2",
        vlm_model="gpt-5.2",
        use_vlm_correction=True,
        use_verification=True
    )
    results_all["gpt52"] = runner2.run_evaluation(prompts)

    # Configuration 3: Hybrid
    print("\n--- [3/3] Hybrid (GPT-4o + GPT-5.2) ---")
    runner3 = PaperEvaluationRunner(
        output_dir=f"{args.output}/hybrid",
        pipeline_model="gpt-4o",
        vlm_model="gpt-5.2",
        use_vlm_correction=True,
        use_verification=True
    )
    results_all["hybrid"] = runner3.run_evaluation(prompts)

    # Generate comparison table
    metrics = generate_table_5_model_ablation(
        results_all["gpt4o"],
        results_all["gpt52"],
        results_all["hybrid"]
    )

    # Save
    output_dir = Path(args.output)
    output_dir.mkdir(parents=True, exist_ok=True)

    table_path = output_dir / "table_5_model_ablation.json"
    with open(table_path, "w") as f:
        json.dump(metrics, f, indent=2)

    # Generate LaTeX
    latex = generate_latex_table_5(metrics)
    latex_path = output_dir / "table_5.tex"
    with open(latex_path, "w") as f:
        f.write(latex)

    # Print summary
    print(f"\n{'='*60}")
    print(f"TABLE 5: MODEL ABLATION RESULTS")
    print(f"{'='*60}")
    print(f"{'Model':<15} {'Compile%':>10} {'Render%':>10} {'Val':>8} {'Parts%':>10} {'Time':>8}")
    print("-" * 60)
    for key, m in metrics.items():
        print(f"{m['model']:<15} {m['compile_rate']:>9.1f}% {m['render_rate']:>9.1f}% "
              f"{m['val_score']:>7.1f} {m['parts_pct']:>9.1f}% {m['avg_time']:>7.1f}s")

    print(f"\nResults saved to: {output_dir}")
    print(f"LaTeX table: {latex_path}")


def generate_latex_table_5(metrics: dict) -> str:
    """Generate LaTeX table for Table 5."""
    rows = []
    for key, m in metrics.items():
        rows.append(f"{m['model']} & {m['compile_rate']:.1f} & {m['render_rate']:.1f} & "
                   f"{m['val_score']:.1f} & {m['parts_pct']:.1f} & {m['avg_time']:.1f}")

    return f"""\\begin{{table}}[h]
\\centering
\\caption{{Model Ablation: All-GPT4o vs All-GPT5.2 vs Hybrid}}
\\label{{tab:model-ablation}}
\\begin{{tabular}}{{lccccc}}
\\toprule
\\textbf{{Model Config}} & \\textbf{{Compile \\%}} & \\textbf{{Render \\%}} & \\textbf{{Val Score}} & \\textbf{{Parts \\%}} & \\textbf{{Time (s)}} \\\\
\\midrule
{' \\\\\n'.join(rows)} \\\\
\\bottomrule
\\end{{tabular}}
\\end{{table}}
"""


if __name__ == "__main__":
    main()
