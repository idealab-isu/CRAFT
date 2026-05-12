"""GPT-5.2 (or GPT-4o) zero-shot baseline runner — Z2C-style 8-image prompt.

This is the apples-to-apples comparison run: same 8 images that CRAFT sees,
fed to GPT-5.2 with a single zero-shot prompt asking for either CadQuery or
OpenSCAD code. Output is parsed, executed to STL, and written under:

    results/zerotocad_eval/{benchmark}/gpt52_{cadquery|openscad}/{uuid}/
        output.{py,scad}
        output.stl
        audit.json

Why both languages: the Comparison-with-Baselines table needs to control for
the "is the win from CRAFT or from OpenSCAD being friendlier?" confound (plan
§7). Running GPT-5.2 in both targets isolates that.
"""

from __future__ import annotations

import argparse
import base64
import json
import os
import re
import sys
import time
import traceback
from pathlib import Path
from typing import List, Optional

from ._common import (
    SampleDirs,
    RunAudit,
    cadquery_to_stl,
    iter_sample_dirs,
    openscad_to_stl,
    stopwatch,
)


_HERE = Path(__file__).resolve()
_REPO_ROOT = _HERE.parents[3]

# Pick up OPENAI_API_KEY / GEMINI_API_KEY from .env at the CRAFT repo root
# (same convention as pipeline/app.py — `python-dotenv` is already a CRAFT dep).
try:
    from dotenv import load_dotenv
    load_dotenv(dotenv_path=_REPO_ROOT / ".env")
    load_dotenv()  # also search cwd / parents as a fallback
except ImportError:
    pass


# Z2C-style zero-shot prompts (reconstructed to match the spirit of their
# "six-line prompt"). Kept terse on purpose — the comparison is meaningful
# only if both models receive a similarly minimal prompt.
_PROMPT_CADQUERY = """You are given 8 rendered views of a 3D CAD shape.
The 8 views are 4 front-facing camera angles plus 4 rear-facing camera angles.

Generate CadQuery code that reproduces this shape. The result must be assigned to
a variable named `result`. Use parametric named variables where reasonable.
Output ONLY valid Python code — no markdown fences, no explanation."""

_PROMPT_OPENSCAD = """You are given 8 rendered views of a 3D CAD shape.
The 8 views are 4 front-facing camera angles plus 4 rear-facing camera angles.

Generate ONE OpenSCAD program that reproduces this shape. Use parametric named
variables where reasonable. Output ONLY valid OpenSCAD source — no markdown
fences, no explanation."""

_SYSTEM_PROMPT = (
    "You are an expert CAD programmer. You receive multi-view renders of a 3D "
    "shape and produce parametric source code that reconstructs it faithfully. "
    "You always output only code."
)


def _img_to_data_url(p: Path) -> str:
    with open(p, "rb") as f:
        b64 = base64.b64encode(f.read()).decode("utf-8")
    return f"data:image/png;base64,{b64}"


def _strip_code_fences(text: str, lang_hint: str = "") -> str:
    """Pull source code out of a markdown response, if present."""
    pat = r"```(?:" + (lang_hint or r"\w+") + r")?\s*([\s\S]*?)```"
    m = re.findall(pat, text)
    if m:
        return m[0].strip()
    return text.strip()


def _call_responses_api(client, model: str, system_prompt: str,
                        user_prompt: str, image_paths: List[Path],
                        max_tokens: int = 4000) -> str:
    """Use the OpenAI Responses API (GPT-5.* models)."""
    content_parts = [{"type": "input_text", "text": user_prompt}]
    for i, p in enumerate(image_paths):
        content_parts.append({"type": "input_text", "text": f"\nVIEW {i}:"})
        content_parts.append({"type": "input_image", "image_url": _img_to_data_url(p)})

    response = client.responses.create(
        model=model,
        instructions=system_prompt,
        input=[{"role": "user", "content": content_parts}],
        max_output_tokens=max_tokens,
    )
    return response.output_text


def _call_chat_completions(client, model: str, system_prompt: str,
                           user_prompt: str, image_paths: List[Path],
                           max_tokens: int = 4000, temperature: float = 0.0) -> str:
    """Use the OpenAI Chat Completions API (GPT-4o-class models)."""
    content_parts = [{"type": "text", "text": user_prompt}]
    for i, p in enumerate(image_paths):
        content_parts.append({"type": "text", "text": f"\nVIEW {i}:"})
        content_parts.append({"type": "image_url",
                              "image_url": {"url": _img_to_data_url(p)}})

    response = client.chat.completions.create(
        model=model,
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": content_parts},
        ],
        temperature=temperature,
        max_tokens=max_tokens,
    )
    return response.choices[0].message.content or ""


def call_gpt(client, model: str, image_paths: List[Path], output_lang: str) -> str:
    """Single zero-shot call; returns raw model text."""
    user_prompt = _PROMPT_CADQUERY if output_lang == "cadquery" else _PROMPT_OPENSCAD
    if model.startswith("gpt-5"):
        return _call_responses_api(client, model, _SYSTEM_PROMPT, user_prompt, image_paths)
    return _call_chat_completions(client, model, _SYSTEM_PROMPT, user_prompt, image_paths)


def run_one(client, model: str, output_lang: str, sample: SampleDirs) -> RunAudit:
    """Run one sample through GPT-5.2 zero-shot → STL."""
    sample.method_out_dir.mkdir(parents=True, exist_ok=True)
    lap = stopwatch()
    audit = RunAudit(
        method=f"gpt52_{output_lang}",
        uuid=sample.uuid,
        output_lang=output_lang,
        success_code=False,
        success_stl=False,
    )

    try:
        raw = call_gpt(client, model, sample.view_paths, output_lang)
        audit.timing_seconds["api_call"] = lap()

        code = _strip_code_fences(raw, lang_hint="python|openscad|scad")
        if len(code) < 20:
            audit.error = "empty_or_trivial_output"
            audit.write(sample.method_out_dir)
            return audit

        code_filename = "output.py" if output_lang == "cadquery" else "output.scad"
        (sample.method_out_dir / code_filename).write_text(code)
        audit.success_code = True

        if output_lang == "cadquery":
            stl = cadquery_to_stl(code, sample.method_out_dir / "output.stl")
        else:
            stl = openscad_to_stl(code, sample.method_out_dir / "output.stl")
        audit.timing_seconds["execution"] = lap()
        audit.success_stl = stl is not None
        if not audit.success_stl:
            audit.error = "execution_failed"

    except Exception as e:
        audit.error = f"{type(e).__name__}: {e}"
        audit.extra["traceback"] = traceback.format_exc(limit=10)

    audit.write(sample.method_out_dir)
    return audit


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--data-root",
        default=str(_REPO_ROOT / "Experimentation/zerotocad_eval/data/ztc_test"),
    )
    parser.add_argument("--out-root", default=None,
                        help="Method output root. Default: results/zerotocad_eval/{ztc_test}/{method}/")
    parser.add_argument("--model", default="gpt-5.2",
                        help="OpenAI model name (default: gpt-5.2).")
    parser.add_argument("--output-lang", choices=["cadquery", "openscad"], required=True,
                        help="Which target language to ask the model for.")
    parser.add_argument("--benchmark", default="ztc_test",
                        help="Benchmark name — used only for the default out-root.")
    parser.add_argument("--limit", type=int, default=None)
    parser.add_argument("--force", action="store_true")
    args = parser.parse_args()

    method_tag = f"gpt52_{args.output_lang}"
    out_root = Path(
        args.out_root
        or _REPO_ROOT / "results" / "zerotocad_eval" / args.benchmark / method_tag
    ).resolve()
    out_root.mkdir(parents=True, exist_ok=True)

    samples = iter_sample_dirs(
        Path(args.data_root).resolve(), out_root,
        limit=args.limit, skip_existing=not args.force,
    )
    print(f"{method_tag} run: {len(samples)} samples → {out_root}")
    if not samples:
        return 0

    try:
        from openai import OpenAI
    except ImportError:
        sys.stderr.write("Install openai: `pip install openai`\n")
        return 1
    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        sys.stderr.write("OPENAI_API_KEY not set.\n")
        return 1
    client = OpenAI(api_key=api_key)

    n_code = n_stl = 0
    for i, s in enumerate(samples, 1):
        print(f"[{i}/{len(samples)}] {s.uuid} …", flush=True)
        audit = run_one(client, args.model, args.output_lang, s)
        n_code += int(audit.success_code)
        n_stl += int(audit.success_stl)
        print(f"      code={audit.success_code} stl={audit.success_stl} err={audit.error}")

    print(f"\nDone. {n_stl}/{len(samples)} STL, {n_code}/{len(samples)} source.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
