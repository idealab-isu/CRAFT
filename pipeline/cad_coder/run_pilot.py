#!/usr/bin/env python3
"""
CAD-Coder Pilot Runner

Run a pilot test of the CadQuery -> OpenSCAD translation pipeline.

Usage:
    python run_pilot.py --n 50 --dataset /path/to/GenCAD-Code/data
    python run_pilot.py --n 10 --model gpt-4o --verbose
"""

import argparse
import os
import sys
from pathlib import Path

# Add parent directories to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from pipeline.cad_coder.config import Config
from pipeline.cad_coder.pipeline import TranslationPipeline


def main():
    parser = argparse.ArgumentParser(
        description="Run CadQuery to OpenSCAD translation pilot",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
    # Run on 50 samples with default settings
    python run_pilot.py --n 50

    # Run on 10 samples with verbose output
    python run_pilot.py --n 10 --verbose

    # Specify custom dataset path
    python run_pilot.py --n 50 --dataset ./GenCAD-Code/data

    # Use specific model and lower SSIM threshold
    python run_pilot.py --n 50 --model gpt-4o --min-ssim 0.6
        """
    )

    # Required/common arguments
    parser.add_argument(
        "--n", "-n",
        type=int,
        default=50,
        help="Number of samples to process (default: 50)"
    )
    parser.add_argument(
        "--dataset", "-d",
        type=str,
        default=None,
        help="Path to GenCAD-Code/data directory"
    )
    parser.add_argument(
        "--output", "-o",
        type=str,
        default=None,
        help="Output directory (default: ./cad_coder_output)"
    )

    # Model settings
    parser.add_argument(
        "--model", "-m",
        type=str,
        default="gpt-4o",
        help="LLM model to use (default: gpt-4o)"
    )
    parser.add_argument(
        "--temperature",
        type=float,
        default=0.2,
        help="LLM temperature (default: 0.2)"
    )

    # Verification thresholds
    parser.add_argument(
        "--min-ssim",
        type=float,
        default=0.70,
        help="Minimum SSIM threshold (default: 0.70)"
    )
    parser.add_argument(
        "--no-watertight",
        action="store_true",
        help="Don't require watertight meshes"
    )

    # Processing options
    parser.add_argument(
        "--max-repair",
        type=int,
        default=2,
        help="Maximum repair attempts (default: 2)"
    )
    parser.add_argument(
        "--translation-only",
        action="store_true",
        help="Skip verification entirely (just translate and save)"
    )
    parser.add_argument(
        "--split",
        type=str,
        default="train",
        choices=["train", "test", "validation"],
        help="Dataset split to use (default: train)"
    )
    parser.add_argument(
        "--offset",
        type=int,
        default=0,
        help="Starting index in dataset (default: 0)"
    )

    # Output options
    parser.add_argument(
        "--verbose", "-v",
        action="store_true",
        help="Verbose output"
    )
    parser.add_argument(
        "--quiet", "-q",
        action="store_true",
        help="Minimal output (only final stats)"
    )

    args = parser.parse_args()

    # Check for OpenAI API key
    if not os.getenv("OPENAI_API_KEY"):
        print("Error: OPENAI_API_KEY environment variable not set")
        print("Please set it with: export OPENAI_API_KEY=your-key-here")
        sys.exit(1)

    # Build configuration
    config = Config(
        model=args.model,
        temperature=args.temperature,
        min_ssim=args.min_ssim,
        require_watertight=not args.no_watertight,
        max_repair_attempts=args.max_repair,
        translation_only=args.translation_only,
    )

    # Resolve dataset path
    dataset_path = args.dataset
    if dataset_path is None:
        # Try default locations
        default_paths = [
            Path(__file__).parent.parent.parent / "craft" / "GenCAD-Code" / "data",
            Path(__file__).parent.parent / "craft" / "GenCAD-Code" / "data",
            Path("./GenCAD-Code/data"),
            Path("../GenCAD-Code/data"),
        ]
        for p in default_paths:
            if p.exists():
                dataset_path = str(p)
                break

    if dataset_path is None or not Path(dataset_path).exists():
        print("Error: Could not find GenCAD-Code dataset")
        print("Please specify the path with --dataset /path/to/GenCAD-Code/data")
        print("\nLooked in:")
        for p in default_paths:
            print(f"  - {p}")
        sys.exit(1)

    # Print banner
    if not args.quiet:
        print("=" * 60)
        print("CAD-CODER PILOT RUN")
        print("=" * 60)
        print(f"Samples:        {args.n}")
        print(f"Dataset:        {dataset_path}")
        print(f"Split:          {args.split}")
        print(f"Model:          {args.model}")
        if args.translation_only:
            print(f"Mode:           TRANSLATION ONLY (no verification)")
        else:
            print(f"Min SSIM:       {args.min_ssim}")
            print(f"Watertight:     {not args.no_watertight}")
            print(f"Max repairs:    {args.max_repair}")
        print("=" * 60)
        print()

    # Create and run pipeline
    pipeline = TranslationPipeline(config=config)

    try:
        stats = pipeline.run(
            n_samples=args.n,
            split=args.split,
            offset=args.offset,
            dataset_path=dataset_path,
            output_dir=args.output,
            verbose=not args.quiet,
        )

        # Return exit code based on success rate
        if stats.success_rate >= 0.8:
            sys.exit(0)  # Great
        elif stats.success_rate >= 0.5:
            sys.exit(0)  # Acceptable
        else:
            sys.exit(1)  # Poor results

    except FileNotFoundError as e:
        print(f"Error: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}")
        if args.verbose:
            import traceback
            traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()
