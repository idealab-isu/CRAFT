#!/usr/bin/env python3
"""
Direct GPT baseline for the Chamfer-distance benchmark.

No CRAFT pipeline: just prompt -> OpenSCAD code -> STL. Works for both
`gpt-4o` (chat/completions with temperature) and `gpt-5.2` (reasoning model
via max_completion_tokens, no temperature). The output directory name is
controlled by --method so filenames line up with run_eval.py's expectations:

    --model gpt-4o   --method gpt4o
    --model gpt-5.2  --method gpt52

Usage
-----
    cd Experimentation/Chamfer_distance
    python benchmark/run_gpt_baseline.py --model gpt-4o  --method gpt4o
    python benchmark/run_gpt_baseline.py --model gpt-5.2 --method gpt52
    python benchmark/run_gpt_baseline.py --model gpt-4o  --method gpt4o -n 10

Outputs per example live in runs/<method>/<id>/:
    prompt.txt   the original bench prompt
    model.scad   cleaned OpenSCAD code
    model.stl    exported STL (also copied to stls/<method>/<id>.stl)
    meta.json    model name, generation time, token counts, export status
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
import time
from pathlib import Path
from typing import Tuple

# Repo paths
HERE = Path(__file__).resolve().parent
CD_ROOT = HERE.parent
REPO_ROOT = CD_ROOT.parent.parent
PIPELINE_DIR = REPO_ROOT / "pipeline"

# Make pipeline utils importable for export_stl
sys.path.insert(0, str(PIPELINE_DIR))
sys.path.insert(0, str(HERE))

from dotenv import load_dotenv            # noqa: E402
from openai import OpenAI                 # noqa: E402
from utils.openscad_runner import export_stl  # noqa: E402

from bench_utils import (                 # noqa: E402
    load_bench_items,
    ensure_ground_truth_copied,
    method_run_dir,
    method_stl_path,
    write_prompt_record,
    print_items,
)

load_dotenv(REPO_ROOT / ".env")
load_dotenv(PIPELINE_DIR / ".env")

# Pick up the keys.json fallback used by pipeline/app.py (OPENAI_API_KEY there).
KEYS_JSON = PIPELINE_DIR / "keys.json"
if not os.getenv("OPENAI_API_KEY") and KEYS_JSON.exists():
    try:
        _keys = json.loads(KEYS_JSON.read_text())
        if "gpt" in _keys:
            os.environ["OPENAI_API_KEY"] = _keys["gpt"]
    except Exception:
        pass


SYSTEM_PROMPT = """You are an OpenSCAD code generator. Generate valid, executable OpenSCAD code based on the user's natural-language CAD description.

Requirements:
1. Output ONLY OpenSCAD code. No explanations, no markdown fences, no prose.
2. The code must render to a non-empty solid; exercise every module you define by calling it at the top level.
3. Use primitives (cube, cylinder, sphere), boolean ops (union, difference, intersection), and transforms (translate, rotate, scale) as appropriate.
4. Respect all dimensions explicitly given in the prompt (in mm unless stated otherwise).
5. Center the final model near the origin when reasonable.
6. Use $fn = 64 or similar for smooth cylinders/spheres.

Output format: raw OpenSCAD code only, starting on the first line."""


USER_TEMPLATE = "Generate OpenSCAD code for: {prompt}\n\nOutput only the raw code."


def clean_code(raw: str) -> str:
    """Strip markdown fences / stray prose around a raw SCAD response."""
    raw = raw.strip()
    if "```" in raw:
        m = re.search(r"```(?:openscad|scad)?\s*\n?(.*?)```", raw, re.DOTALL)
        if m:
            raw = m.group(1)
    return raw.strip()


def call_model(client: OpenAI, model: str, prompt: str) -> Tuple[str, dict]:
    """Return (scad_code, meta_dict).

    Direct prompt -> SCAD call with a fixed 4000-token completion budget for
    every model. Classic chat models also get temperature=0.2 for mildly
    deterministic output; newer models (gpt-5.x / o-series) are called with
    default sampling since they do not accept the temperature argument.
    """
    is_new_api = model.startswith("gpt-5") or model.startswith("o1") or model.startswith("o3")

    kwargs = {
        "model": model,
        "messages": [
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": USER_TEMPLATE.format(prompt=prompt)},
        ],
    }
    if is_new_api:
        kwargs["max_completion_tokens"] = 4000
    else:
        kwargs["temperature"] = 0.2
        kwargs["max_tokens"] = 4000

    t0 = time.time()
    resp = client.chat.completions.create(**kwargs)
    dt = time.time() - t0

    raw = resp.choices[0].message.content or ""
    usage = getattr(resp, "usage", None)
    meta = {
        "model": model,
        "seconds": dt,
        "usage": {
            "prompt_tokens": getattr(usage, "prompt_tokens", None),
            "completion_tokens": getattr(usage, "completion_tokens", None),
            "total_tokens": getattr(usage, "total_tokens", None),
        } if usage else None,
    }
    return clean_code(raw), meta


def run(model: str, method: str, n: int, stratified: bool) -> None:
    if not os.getenv("OPENAI_API_KEY"):
        sys.exit("ERROR: OPENAI_API_KEY not set (env, .env, or pipeline/keys.json).")

    items = load_bench_items(n=n, stratified=stratified)
    ensure_ground_truth_copied(items)
    print_items(items)

    client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

    summary = {"model": model, "method": method, "n": n, "items": []}
    ok_count = 0

    for i, item in enumerate(items, 1):
        run_dir = method_run_dir(method, item.id)
        write_prompt_record(run_dir, item)

        print(f"[{i:2d}/{n}] {item.id}  ({item.tier})")
        entry = {"id": item.id, "tier": item.tier}

        try:
            code, meta = call_model(client, model, item.prompt)
        except Exception as exc:
            msg = f"API call failed: {exc}"
            print(f"     API ERROR: {msg}")
            entry["error"] = msg
            summary["items"].append(entry)
            continue

        entry.update(meta)

        scad_path = run_dir / "model.scad"
        scad_path.write_text(code)
        print(f"     wrote {scad_path.relative_to(CD_ROOT)}  ({len(code)} chars, {meta['seconds']:.1f}s)")

        # Export STL
        stl_path = run_dir / "model.stl"
        t0 = time.time()
        ok, err = export_stl(str(scad_path), str(stl_path), timeout=180)
        export_secs = time.time() - t0
        entry["export_seconds"] = export_secs
        entry["export_ok"] = ok
        if not ok:
            entry["export_error"] = err[:500] if err else ""
            print(f"     STL EXPORT FAILED: {(err or '')[:120]}")
        else:
            final_stl = method_stl_path(method, item.id)
            final_stl.write_bytes(stl_path.read_bytes())
            print(f"     STL  -> {final_stl.relative_to(CD_ROOT)}  ({stl_path.stat().st_size // 1024} KB, {export_secs:.1f}s)")
            ok_count += 1

        summary["items"].append(entry)

    summary["ok"] = ok_count
    out_json = CD_ROOT / "runs" / method / "summary.json"
    out_json.parent.mkdir(parents=True, exist_ok=True)
    out_json.write_text(json.dumps(summary, indent=2))

    print()
    print(f"Done. {ok_count}/{n} STLs produced for {method} ({model}).")
    print(f"Summary: {out_json.relative_to(CD_ROOT)}")
    print(f"Final STLs for run_eval: stls/{method}/*.stl")


def parse_args() -> argparse.Namespace:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--model", required=True, help="OpenAI model id, e.g. gpt-4o or gpt-5.2")
    ap.add_argument("--method", required=True, help="Output dir name under stls/ and runs/ (e.g. gpt4o, gpt52)")
    ap.add_argument("-n", "--num-examples", type=int, default=30, help="Number of bench prompts to run")
    ap.add_argument("--stratified", action="store_true",
                    help="Round-robin across component families for shape diversity "
                         "(recommended for small n; the JSON is alphabetically sorted "
                         "so without this flag the first 30 items are dominated by "
                         "the first few families).")
    return ap.parse_args()


if __name__ == "__main__":
    args = parse_args()
    run(model=args.model, method=args.method, n=args.num_examples, stratified=args.stratified)
