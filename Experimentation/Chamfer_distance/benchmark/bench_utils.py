"""
Shared helpers for the Chamfer-distance benchmark:

- Select the first N prompts from benchmark_ground_truth_v2.json.
- Copy the matching ground-truth STLs into stls/ground_truth/.
- Resolve the per-method output directories under runs/ and stls/.

Example IDs are used as filename stems across all methods (GT, CRAFT, GPT-4o,
GPT-5.2) so run_eval.py can pair them automatically.
"""

from __future__ import annotations

import json
import shutil
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List

HERE = Path(__file__).resolve().parent
CD_ROOT = HERE.parent                                          # .../Chamfer_distance
REPO_ROOT = CD_ROOT.parent.parent                              # .../CRAFT
GT_ROOT = CD_ROOT.parent / "GroundTruth"                       # .../Experimentation/GroundTruth

GT_JSON = GT_ROOT / "benchmark_ground_truth_v2.json"
GT_STL_DIR = GT_ROOT / "stl"

STLS_DIR = CD_ROOT / "stls"
RUNS_DIR = CD_ROOT / "runs"

GROUND_TRUTH_STL_DIR = STLS_DIR / "ground_truth"


@dataclass
class BenchItem:
    """One prompt from the benchmark."""
    id: str              # e.g. "7_segment__WT5011BSR" — used as filename stem
    prompt: str
    tier: str
    gt_stl: Path         # path to the ground-truth STL


def _load_all_valid_items() -> List[BenchItem]:
    """All bench items whose ground-truth STL exists, in JSON order."""
    if not GT_JSON.exists():
        raise FileNotFoundError(f"Ground-truth file not found: {GT_JSON}")

    data = json.loads(GT_JSON.read_text())
    components = data.get("components", [])

    items: List[BenchItem] = []
    for c in components:
        cid = c.get("id")
        prompt = c.get("prompt")
        tier = c.get("tier", "")
        if not cid or not prompt:
            continue
        gt_stl = GT_STL_DIR / f"{cid}.stl"
        if not gt_stl.exists():
            continue
        items.append(BenchItem(id=cid, prompt=prompt, tier=tier, gt_stl=gt_stl))
    return items


def load_bench_items(n: int = 30, stratified: bool = False) -> List[BenchItem]:
    """Select `n` prompts from benchmark_ground_truth_v2.json.

    Parameters
    ----------
    n : int
        Number of prompts to return.
    stratified : bool, default False
        If False, return the first `n` items in JSON order (the file is
        sorted alphabetically by family, so low-n slices are heavily biased
        toward whatever family sorts first — typically ball_bearing).
        If True, round-robin across families in alphabetical order picking
        one item per family before re-visiting any family, which maximises
        shape diversity for small n.

    Raises if fewer than `n` valid items are available.
    """
    all_items = _load_all_valid_items()

    if stratified:
        by_family: Dict[str, List[BenchItem]] = {}
        for it in all_items:
            fam = it.id.split("__", 1)[0]
            by_family.setdefault(fam, []).append(it)

        families = sorted(by_family.keys())
        queues = {f: list(by_family[f]) for f in families}

        picked: List[BenchItem] = []
        while len(picked) < n:
            progressed = False
            for f in families:
                if queues[f]:
                    picked.append(queues[f].pop(0))
                    progressed = True
                    if len(picked) >= n:
                        break
            if not progressed:
                break
        items = picked
    else:
        items = all_items[:n]

    if len(items) < n:
        raise RuntimeError(
            f"Only found {len(items)} bench items with GT STLs; needed {n}"
        )
    return items


def ensure_ground_truth_copied(items: List[BenchItem]) -> None:
    """Copy each ground-truth STL into stls/ground_truth/<id>.stl."""
    GROUND_TRUTH_STL_DIR.mkdir(parents=True, exist_ok=True)
    for item in items:
        dst = GROUND_TRUTH_STL_DIR / f"{item.id}.stl"
        if dst.exists() and dst.stat().st_size == item.gt_stl.stat().st_size:
            continue
        shutil.copy2(item.gt_stl, dst)


def method_run_dir(method: str, item_id: str) -> Path:
    """Per-example artifact directory, e.g. runs/craft/<id>/."""
    p = RUNS_DIR / method / item_id
    p.mkdir(parents=True, exist_ok=True)
    return p


def method_stl_path(method: str, item_id: str) -> Path:
    """Final STL location consumed by run_eval.py: stls/<method>/<id>.stl."""
    p = STLS_DIR / method / f"{item_id}.stl"
    p.parent.mkdir(parents=True, exist_ok=True)
    return p


def write_prompt_record(run_dir: Path, item: BenchItem) -> None:
    """Drop a prompt.txt next to the artifacts for traceability."""
    (run_dir / "prompt.txt").write_text(
        f"id   : {item.id}\n"
        f"tier : {item.tier}\n\n"
        f"{item.prompt}\n"
    )


def print_items(items: List[BenchItem]) -> None:
    print(f"Loaded {len(items)} benchmark items:")
    for i, it in enumerate(items, 1):
        print(f"  [{i:2d}] {it.id:40s} ({it.tier:7s})  {it.prompt[:70]}")
    print()
