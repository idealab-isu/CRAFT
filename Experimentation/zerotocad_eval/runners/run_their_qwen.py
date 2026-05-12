"""Run ADSKAILab/Zero-To-CAD-Qwen3-VL-2B on identical samples.

This is Their fine-tuned model — the 2B Qwen3-VL Ataei et al. trained on the
979K training split. We re-run it on the SAME samples we feed CRAFT so the
comparison is sample-matched, not just protocol-matched (plan §7, §10 Phase 3).

The user must have:
  - `transformers` and `torch` installed.
  - Enough VRAM to load the 2B model in bf16 (~5 GB; runs on most workstations
    with a 6+ GB GPU, or on CPU/MPS at much lower throughput).
  - First-run download of ~5 GB from HuggingFace.

The exact preprocessing (image channel order, value range, chat template)
must come from the model card via `AutoProcessor`. Don't hand-roll it. If
HuggingFace's `Zero-To-CAD-Qwen3-VL-2B` ships its own inference script in
the repo, prefer it over what's here.
"""

from __future__ import annotations

import argparse
import os
import re
import sys
import traceback
from pathlib import Path
from typing import List, Optional

from ._common import (
    SampleDirs,
    RunAudit,
    cadquery_to_stl,
    iter_sample_dirs,
    stopwatch,
)


_HERE = Path(__file__).resolve()
_REPO_ROOT = _HERE.parents[3]

# Pick up HF_TOKEN / cache settings from CRAFT's .env if present.
try:
    from dotenv import load_dotenv
    load_dotenv(dotenv_path=_REPO_ROOT / ".env")
    load_dotenv()
except ImportError:
    pass

DEFAULT_MODEL_ID = "ADSKAILab/Zero-To-CAD-Qwen3-VL-2B"


def _strip_fences(text: str) -> str:
    """Z2C's model emits CadQuery; some checkpoints wrap it in markdown."""
    m = re.findall(r"```(?:python|cadquery)?\s*([\s\S]*?)```", text)
    return (m[0] if m else text).strip()


class TheirQwenRunner:
    """Lazy-init wrapper so we load the model at most once per process."""

    def __init__(self, model_id: str = DEFAULT_MODEL_ID, dtype: str = "auto",
                 device_map: str = "auto"):
        self.model_id = model_id
        self.dtype = dtype
        self.device_map = device_map
        self._processor = None
        self._model = None

    def _ensure_loaded(self):
        if self._model is not None:
            return
        try:
            import transformers
            from transformers import AutoProcessor
            import torch  # noqa: F401
        except ImportError as e:
            raise RuntimeError(
                "transformers and torch are required. Install with:\n"
                "  pip install --upgrade transformers torch pillow\n"
                f"({e})"
            )

        print(f"[their_qwen] Loading {self.model_id} (transformers {transformers.__version__}) …",
              flush=True)
        self._processor = AutoProcessor.from_pretrained(
            self.model_id, trust_remote_code=True
        )

        # Qwen3-VL ships as `transformers.models.qwen3_vl.Qwen3VLForConditionalGeneration`.
        # In transformers 4.57.x it is NOT re-exported on the top-level
        # `transformers` namespace, so `getattr(transformers, ...)` silently
        # returned None and our previous loop fell through to AutoModelForCausalLM
        # (which doesn't register Qwen3VL).
        #
        # Strategy now: try in order, capture EVERY failure for diagnostics:
        #   1. Direct submodule import of Qwen3VLForConditionalGeneration.
        #   2. AutoModelForImageTextToText (the canonical Auto-class for VLMs).
        #   3. AutoModelForVision2Seq (older Auto-class name).
        #   4. AutoModelForCausalLM (last-ditch, almost never works for VLMs).
        #
        # device_map="auto" requires the `accelerate` package. We only set it
        # if accelerate is importable; otherwise we load on CPU and manually
        # move to MPS/CUDA after.
        try:
            import accelerate  # noqa: F401
            _have_accelerate = True
        except ImportError:
            _have_accelerate = False
            print("[their_qwen] accelerate not installed — loading without "
                  "device_map and moving manually after load.", flush=True)

        # Pick a concrete dtype based on the target device.
        # - MPS (Apple Silicon): bfloat16 is NOT supported → use float16.
        # - CUDA: bfloat16 is fine → leave "auto" so transformers reads the
        #   checkpoint's saved dtype (bf16 for Qwen3-VL).
        # - CPU: use float32 for safety; bf16 inference on CPU is slow and
        #   sometimes buggy in older PyTorch.
        import torch as _torch
        if self.dtype == "auto":
            if _torch.backends.mps.is_available():
                effective_dtype = _torch.float16
                print("[their_qwen] MPS detected → forcing float16 "
                      "(bfloat16 is unsupported on MPS).", flush=True)
            elif _torch.cuda.is_available():
                effective_dtype = "auto"
            else:
                effective_dtype = _torch.float32
                print("[their_qwen] CPU only → using float32.", flush=True)
        else:
            effective_dtype = self.dtype

        # transformers 4.57+ renames the kwarg from `torch_dtype` to `dtype`
        # but the old name still works (with a deprecation warning). Use the
        # new name to keep the log clean.
        load_kwargs = dict(
            dtype=effective_dtype,
            trust_remote_code=True,
        )
        # On MPS, accelerate's `device_map="auto"` can decide to offload
        # some weights to disk (the "Some parameters are on the meta device"
        # message), which is both slow and known to interact badly with the
        # numpy 2.x ABI break in older torch. So on MPS we skip device_map
        # entirely and just `.to("mps")` after load (single contiguous move).
        # On CUDA, accelerate's smart placement is actually helpful — keep it.
        _used_device_map = False
        if _have_accelerate and _torch.cuda.is_available():
            load_kwargs["device_map"] = self.device_map
            _used_device_map = True
        elif _have_accelerate:
            print("[their_qwen] skipping device_map on MPS — will move "
                  "manually after load (avoids disk offload).", flush=True)

        candidates = []

        # 1. Direct submodule import
        try:
            from transformers.models.qwen3_vl import Qwen3VLForConditionalGeneration
            candidates.append(("Qwen3VLForConditionalGeneration (direct)",
                               Qwen3VLForConditionalGeneration))
        except (ImportError, AttributeError):
            pass

        # 2-4. AutoClass fallbacks
        for cls_name in (
            "AutoModelForImageTextToText",
            "AutoModelForVision2Seq",
            "AutoModelForCausalLM",
        ):
            ModelClass = getattr(transformers, cls_name, None)
            if ModelClass is not None:
                candidates.append((cls_name, ModelClass))

        if not candidates:
            raise RuntimeError(
                f"transformers={transformers.__version__} has no usable loader "
                f"for Qwen3-VL. Upgrade with: "
                f"pip install -U git+https://github.com/huggingface/transformers.git"
            )

        errors: List[str] = []
        for label, ModelClass in candidates:
            try:
                self._model = ModelClass.from_pretrained(self.model_id, **load_kwargs)
                print(f"[their_qwen] Loaded via {label}.", flush=True)
                break
            except Exception as e:
                msg = str(e).replace("\n", " ")[:240]
                errors.append(f"{label}: {type(e).__name__}: {msg}")

        if self._model is None:
            detail = "\n  ".join(errors)
            raise RuntimeError(
                f"All loader strategies failed for {self.model_id}.\n"
                f"  {detail}\n"
                "Hints:\n"
                "  - pip install accelerate                 (for device_map support)\n"
                "  - pip install transformers==4.57.6      (avoid 5.x which needs torch>=2.4)"
            )

        # Manual placement if we loaded without device_map (MPS or no-accelerate).
        if not _used_device_map:
            import torch
            if torch.backends.mps.is_available():
                target = "mps"
            elif torch.cuda.is_available():
                target = "cuda"
            else:
                target = "cpu"
            print(f"[their_qwen] moving model to {target} …", flush=True)
            self._model = self._model.to(target)

        self._model.eval()
        device = getattr(self._model, "device", None)
        print(f"[their_qwen] device={device}", flush=True)

    def generate(self, image_paths: List[Path],
                 instruction: str = "Generate CadQuery code for this shape.",
                 max_new_tokens: int = 2048) -> str:
        self._ensure_loaded()
        from PIL import Image

        images = [Image.open(str(p)).convert("RGB") for p in image_paths]
        content: list = [{"type": "image", "image": img} for img in images]
        content.append({"type": "text", "text": instruction})
        messages = [{"role": "user", "content": content}]

        # NB: apply_chat_template + processor() is the canonical Qwen-VL
        # inference flow. If their checkpoint customizes this (e.g. requires
        # a system prompt), the model card supersedes.
        text = self._processor.apply_chat_template(
            messages, tokenize=False, add_generation_prompt=True
        )
        inputs = self._processor(
            text=[text], images=images, padding=True, return_tensors="pt"
        )
        inputs = {k: v.to(self._model.device) if hasattr(v, "to") else v
                  for k, v in inputs.items()}

        import torch
        with torch.inference_mode():
            generated = self._model.generate(
                **inputs,
                max_new_tokens=max_new_tokens,
                do_sample=False,
                temperature=1.0,
            )

        # Trim the prompt tokens off the front before decoding.
        input_len = inputs["input_ids"].shape[1]
        new_tokens = generated[:, input_len:]
        out = self._processor.batch_decode(new_tokens, skip_special_tokens=True)
        return out[0] if out else ""


def run_one(runner: TheirQwenRunner, sample: SampleDirs) -> RunAudit:
    sample.method_out_dir.mkdir(parents=True, exist_ok=True)
    lap = stopwatch()
    audit = RunAudit(
        method="their_qwen", uuid=sample.uuid, output_lang="cadquery",
        success_code=False, success_stl=False,
    )

    try:
        raw = runner.generate(sample.view_paths)
        audit.timing_seconds["generate"] = lap()

        code = _strip_fences(raw)
        if len(code) < 20:
            audit.error = "empty_or_trivial_output"
            audit.write(sample.method_out_dir)
            return audit

        (sample.method_out_dir / "output.py").write_text(code)
        audit.success_code = True

        stl = cadquery_to_stl(code, sample.method_out_dir / "output.stl")
        audit.timing_seconds["execution"] = lap()
        audit.success_stl = stl is not None
        if not audit.success_stl:
            audit.error = "cadquery_exec_failed"

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
    parser.add_argument("--out-root", default=None)
    parser.add_argument("--benchmark", default="ztc_test")
    parser.add_argument("--model-id", default=DEFAULT_MODEL_ID)
    parser.add_argument("--limit", type=int, default=None)
    parser.add_argument("--force", action="store_true")
    args = parser.parse_args()

    out_root = Path(
        args.out_root
        or _REPO_ROOT / "results" / "zerotocad_eval" / args.benchmark / "their_qwen"
    ).resolve()
    out_root.mkdir(parents=True, exist_ok=True)

    samples = iter_sample_dirs(
        Path(args.data_root).resolve(), out_root,
        limit=args.limit, skip_existing=not args.force,
    )
    print(f"Their Qwen run: {len(samples)} samples → {out_root}")
    if not samples:
        return 0

    runner = TheirQwenRunner(model_id=args.model_id)
    n_code = n_stl = 0
    for i, s in enumerate(samples, 1):
        print(f"[{i}/{len(samples)}] {s.uuid} …", flush=True)
        audit = run_one(runner, s)
        n_code += int(audit.success_code)
        n_stl += int(audit.success_stl)
        print(f"      code={audit.success_code} stl={audit.success_stl} err={audit.error}")

    print(f"\nDone. {n_stl}/{len(samples)} STL, {n_code}/{len(samples)} source.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
