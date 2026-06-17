"""
One-shot path patcher used during the Phase 0a reorganization.

Old layout had:
  CRAFT-LAD/evaluation/<script>.py  with  CRAFT_DIR = SCRIPT_DIR.parent / "craft"
                                          (broken — code dir was "pipeline", not "craft")

New layout:
  CRAFT-LAD/experiments/{01_ground_truth,02_benchmark,03_metrics/_shared}/<script>.py
  CRAFT-LAD/pipeline/                   (the actual code dir)
  CRAFT-LAD/ground_truth/nopscadlib/    (the GT dir)
  CRAFT-LAD/results/{nopscadlib,abc,slice100k}/...

This script patches every moved script in-place so its hard-coded path constants
land in the right place under the new layout. Idempotent: re-running is a no-op.
"""
from __future__ import annotations
import re
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent

# script path  →  list of (old_substring, new_substring) patches
PATCHES: dict[str, list[tuple[str, str]]] = {
    # ── ground-truth scripts ────────────────────────────────────────────────
    "experiments/01_ground_truth/compute_complexity.py": [
        ('SCRIPT_DIR = Path(__file__).parent\n'
         'CATALOG_PATH = SCRIPT_DIR / "nopscadlib_component_catalog.json"\n'
         'RENDER_RESULTS_PATH = SCRIPT_DIR / "ground_truth" / "render_results.json"\n'
         'OUTPUT_PATH = SCRIPT_DIR / "benchmark_ground_truth.json"\n',
         'SCRIPT_DIR = Path(__file__).parent\n'
         'REPO_ROOT = SCRIPT_DIR.parent.parent\n'
         'GT_DIR = REPO_ROOT / "ground_truth" / "nopscadlib"\n'
         'CATALOG_PATH = GT_DIR / "nopscadlib_component_catalog.json"\n'
         'RENDER_RESULTS_PATH = GT_DIR / "render_results.json"\n'
         'OUTPUT_PATH = GT_DIR / "benchmark_ground_truth.json"\n'),
        ('CRAFT_DIR = SCRIPT_DIR.parent / "craft"',
         'CRAFT_DIR = REPO_ROOT / "pipeline"'),
    ],
    "experiments/01_ground_truth/external_gt.py": [
        ('SCRIPT_DIR = Path(__file__).parent\n'
         'CRAFT_DIR = SCRIPT_DIR.parent / "craft"\n',
         'SCRIPT_DIR = Path(__file__).parent\n'
         'REPO_ROOT = SCRIPT_DIR.parent.parent\n'
         'CRAFT_DIR = REPO_ROOT / "pipeline"\n'),
        ('SCRIPT_DIR / f"{args.dataset_name}_ground_truth.json"',
         'REPO_ROOT / "ground_truth" / args.dataset_name / f"{args.dataset_name}_ground_truth.json"'),
    ],
    "experiments/01_ground_truth/nopscadlib_gt.py": [
        ('SCRIPT_DIR = Path(__file__).parent\n'
         'CATALOG_PATH = SCRIPT_DIR / "nopscadlib_component_catalog.json"\n'
         'GROUND_TRUTH_DIR = SCRIPT_DIR / "ground_truth"\n',
         'SCRIPT_DIR = Path(__file__).parent\n'
         'REPO_ROOT = SCRIPT_DIR.parent.parent\n'
         'GT_DIR = REPO_ROOT / "ground_truth" / "nopscadlib"\n'
         'CATALOG_PATH = GT_DIR / "nopscadlib_component_catalog.json"\n'
         'GROUND_TRUTH_DIR = GT_DIR\n'),
        ('CRAFT_DIR = SCRIPT_DIR.parent / "craft"',
         'CRAFT_DIR = REPO_ROOT / "pipeline"'),
    ],
    "experiments/01_ground_truth/render_nopscadlib.py": [
        ('SCRIPT_DIR = Path(__file__).parent\n'
         'GROUND_TRUTH_DIR = SCRIPT_DIR / "ground_truth"\n',
         'SCRIPT_DIR = Path(__file__).parent\n'
         'REPO_ROOT = SCRIPT_DIR.parent.parent\n'
         'GROUND_TRUTH_DIR = REPO_ROOT / "ground_truth" / "nopscadlib"\n'),
        ('CRAFT_DIR = SCRIPT_DIR.parent / "craft"',
         'CRAFT_DIR = REPO_ROOT / "pipeline"'),
    ],

    # ── benchmark runners ──────────────────────────────────────────────────
    "experiments/02_benchmark/run_craft.py": [
        ('SCRIPT_DIR = Path(__file__).parent\n'
         'CRAFT_DIR = SCRIPT_DIR.parent / "craft"\n',
         'SCRIPT_DIR = Path(__file__).parent\n'
         'REPO_ROOT = SCRIPT_DIR.parent.parent\n'
         'CRAFT_DIR = REPO_ROOT / "pipeline"\n'),
        ('self.output_dir = Path(output_dir or SCRIPT_DIR / "results" / "craft")',
         'self.output_dir = Path(output_dir or REPO_ROOT / "results" / "nopscadlib" / "craft")'),
        ('gt_path = SCRIPT_DIR / "benchmark_ground_truth.json"',
         'gt_path = REPO_ROOT / "ground_truth" / "nopscadlib" / "benchmark_ground_truth.json"'),
    ],
    "experiments/02_benchmark/run_external.py": [
        ('SCRIPT_DIR = Path(__file__).parent\n'
         'CRAFT_DIR = SCRIPT_DIR.parent / "craft"\n',
         'SCRIPT_DIR = Path(__file__).parent\n'
         'REPO_ROOT = SCRIPT_DIR.parent.parent\n'
         'CRAFT_DIR = REPO_ROOT / "pipeline"\n'),
        ('base_dir = SCRIPT_DIR / "results" / f"ext_{args.dataset_name}"',
         'base_dir = REPO_ROOT / "results" / args.dataset_name'),
    ],
    "experiments/02_benchmark/run_external_metrics.py": [
        # this script imports the shared metric module that moved
        ('SCRIPT_DIR = Path(__file__).parent\n'
         'sys.path.insert(0, str(SCRIPT_DIR))\n',
         'SCRIPT_DIR = Path(__file__).parent\n'
         'REPO_ROOT = SCRIPT_DIR.parent.parent\n'
         'sys.path.insert(0, str(REPO_ROOT / "experiments" / "03_metrics" / "_shared"))\n'),
        ('from evaluate_benchmark import',
         'from geometric import'),
    ],
}


def main() -> int:
    n_patched = 0
    n_already = 0
    n_missing = 0
    for rel_path, patches in PATCHES.items():
        path = REPO_ROOT / rel_path
        if not path.exists():
            print(f"  MISSING: {rel_path}")
            n_missing += 1
            continue
        text = path.read_text(encoding="utf-8")
        original = text
        for old, new in patches:
            if old in text:
                text = text.replace(old, new, 1)
            elif new in text:
                # idempotent — already patched
                pass
            else:
                print(f"  WARN: patch not applied in {rel_path}: {old[:60].strip()!r}")
        if text != original:
            path.write_text(text, encoding="utf-8")
            print(f"  patched: {rel_path}")
            n_patched += 1
        else:
            print(f"  already: {rel_path}")
            n_already += 1
    print(f"\nDone. {n_patched} patched, {n_already} already up to date, {n_missing} missing.")
    return 0 if n_missing == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
