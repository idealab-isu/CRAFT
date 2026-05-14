"""Stream the Zero-to-CAD test split and decode each row into a per-sample folder.

The dataset is published as `ADSKAILab/Zero-To-CAD-1m` on HuggingFace (Apache
2.0). The full repo is ~349 GB, but the test split is only ~3-4 GB; we use
`streaming=True` so HF pulls shards on demand and we never materialize the
parquet cache. Final on-disk footprint is the decoded per-sample folders.

Per-sample layout written by this script:

    {out_dir}/{uuid}/
        views/view_0.png   ... views/view_7.png    (4 front + 4 rear, 256x256)
        gt.stl                                     (ground-truth mesh)
        gt.step                                    (ground-truth STEP)
        meta.json                                  (uuid, num_faces, ops, cadquery source)

Usage:

    # smoke test
    python -m Experimentation.zerotocad_eval.fetch_ztc_test --limit 5

    # pilot
    python -m Experimentation.zerotocad_eval.fetch_ztc_test --limit 50

    # full headline pool (10K samples, ~3-4 GB on disk)
    python -m Experimentation.zerotocad_eval.fetch_ztc_test

Requires `datasets` and `Pillow` (see requirements.txt; install with:
`pip install datasets pillow tqdm`).
"""

from __future__ import annotations

import argparse
import base64
import io
import json
import sys
from pathlib import Path
from typing import Any, Dict


# ---------------------------------------------------------------------------
# Field coercion helpers
#
# The parquet schema documents image_0..image_7 as raw PNG bytes and stl_file
# / step_file as raw bytes. In practice the HuggingFace `datasets` library may
# auto-decode any field annotated as an `Image` feature into a PIL.Image.Image
# object, or wrap it in `{"bytes": ..., "path": ...}` if it's stored as a
# Sequence(Value("binary")). We handle all three shapes so the script doesn't
# break on a future schema tweak.
# ---------------------------------------------------------------------------


def _to_png_bytes(value: Any) -> bytes:
    """Coerce a parquet image field into PNG-encoded bytes."""
    if isinstance(value, (bytes, bytearray)):
        return bytes(value)
    if hasattr(value, "save"):  # PIL.Image.Image
        buf = io.BytesIO()
        value.save(buf, format="PNG")
        return buf.getvalue()
    if isinstance(value, dict):
        if value.get("bytes") is not None:
            return bytes(value["bytes"])
        if value.get("path"):
            return Path(value["path"]).read_bytes()
    raise TypeError(f"Unrecognized image field type: {type(value).__name__}")


def _to_raw_bytes(value: Any) -> bytes:
    """Coerce a parquet binary field (STL/STEP) into raw bytes."""
    if isinstance(value, (bytes, bytearray)):
        return bytes(value)
    if isinstance(value, dict):
        if value.get("bytes") is not None:
            return bytes(value["bytes"])
        if value.get("path"):
            return Path(value["path"]).read_bytes()
    if isinstance(value, str):
        # base64-encoded fallback
        return base64.b64decode(value)
    raise TypeError(f"Unrecognized binary field type: {type(value).__name__}")


def _decode_cadquery_source(value: Any) -> str:
    """Return CadQuery source as a UTF-8 string.

    The model card pattern is `bytes(sample["cadquery_file"]).decode("utf-8")`.
    Some snapshots wrap the source in base64; we try utf-8 first and fall back
    to base64-decoding if the utf-8 result doesn't look like CadQuery code.
    """
    if isinstance(value, str):
        raw = value.encode()
    else:
        raw = _to_raw_bytes(value)

    try:
        text = raw.decode("utf-8")
        if "cadquery" in text.lower() or "cq." in text or "import " in text:
            return text
    except UnicodeDecodeError:
        text = None

    try:
        return base64.b64decode(raw).decode("utf-8")
    except Exception:
        return raw.decode("utf-8", errors="replace") if text is None else text


# ---------------------------------------------------------------------------
# Per-sample writer
# ---------------------------------------------------------------------------


def write_sample(out_dir: Path, sample: Dict[str, Any]) -> None:
    """Decode one parquet row into the per-sample folder convention."""
    uuid = sample["uuid"]
    folder = out_dir / uuid
    views_dir = folder / "views"
    views_dir.mkdir(parents=True, exist_ok=True)

    for i in range(8):
        key = f"image_{i}"
        if key not in sample:
            raise KeyError(f"Sample {uuid} is missing field {key}")
        (views_dir / f"view_{i}.png").write_bytes(_to_png_bytes(sample[key]))

    if "stl_file" in sample and sample["stl_file"] is not None:
        (folder / "gt.stl").write_bytes(_to_raw_bytes(sample["stl_file"]))
    if "step_file" in sample and sample["step_file"] is not None:
        (folder / "gt.step").write_bytes(_to_raw_bytes(sample["step_file"]))

    meta = {
        "uuid": uuid,
        "num_faces": int(sample.get("num_faces", -1)) if sample.get("num_faces") is not None else None,
        "cadquery_ops_json": sample.get("cadquery_ops_json"),
        "cadquery_file": _decode_cadquery_source(sample["cadquery_file"])
        if sample.get("cadquery_file") is not None
        else None,
    }
    (folder / "meta.json").write_text(json.dumps(meta, indent=2), encoding="utf-8")


def _is_sample_complete(folder: Path) -> bool:
    """A sample is 'done' iff meta.json and all 8 views + gt.stl exist."""
    if not (folder / "meta.json").exists():
        return False
    if not (folder / "gt.stl").exists():
        return False
    views_dir = folder / "views"
    if not views_dir.is_dir():
        return False
    return all((views_dir / f"view_{i}.png").exists() for i in range(8))


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Fetch & decode the Zero-To-CAD test split."
    )
    parser.add_argument(
        "--out-dir",
        default="Experimentation/zerotocad_eval/data/ztc_test",
        help="Destination folder (per-sample UUID subfolders are created here).",
    )
    parser.add_argument(
        "--limit",
        type=int,
        default=None,
        help="Stop after this many samples (default: pull the entire 10K split).",
    )
    parser.add_argument(
        "--repo",
        default="ADSKAILab/Zero-To-CAD-1m",
        help="HuggingFace dataset repo id.",
    )
    parser.add_argument(
        "--split",
        default="test",
        help="Dataset split to pull (default: test). Do NOT use train/val — Their model is contaminated on those.",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="Re-decode samples even if the destination folder is already complete.",
    )
    args = parser.parse_args()

    out_dir = Path(args.out_dir).resolve()
    out_dir.mkdir(parents=True, exist_ok=True)

    try:
        from datasets import load_dataset
    except ImportError:
        sys.stderr.write(
            "Missing 'datasets' package. Install with:\n"
            "    pip install datasets pillow tqdm\n"
        )
        return 1

    try:
        from tqdm import tqdm
    except ImportError:  # tqdm is optional
        def tqdm(x=None, **_):  # type: ignore[no-redef]
            class _Bar:
                def update(self, n=1): pass
                def close(self): pass
                def set_postfix_str(self, s): pass
            return _Bar()

    print(f"Streaming {args.repo} split={args.split} → {out_dir}")
    if args.limit is not None:
        print(f"Limit: {args.limit} samples")

    ds = load_dataset(args.repo, split=args.split, streaming=True)

    written = 0
    skipped = 0
    errors = 0
    pbar = tqdm(total=args.limit, unit="sample", desc="ZTC test")

    for sample in ds:
        if args.limit is not None and (written + skipped) >= args.limit:
            break

        uuid = sample.get("uuid")
        if not uuid:
            errors += 1
            sys.stderr.write("[error] sample with no uuid; skipping\n")
            continue

        target = out_dir / uuid
        if (not args.force) and _is_sample_complete(target):
            skipped += 1
            pbar.update(1)
            pbar.set_postfix_str(f"wrote={written} skip={skipped} err={errors}")
            continue

        try:
            write_sample(out_dir, sample)
            written += 1
        except Exception as e:  # decode failures are reportable, not fatal
            errors += 1
            sys.stderr.write(f"[error] {uuid}: {type(e).__name__}: {e}\n")

        pbar.update(1)
        pbar.set_postfix_str(f"wrote={written} skip={skipped} err={errors}")

    pbar.close()
    print(f"Done. wrote={written} skipped={skipped} errors={errors}")
    return 0 if errors == 0 else 2


if __name__ == "__main__":
    raise SystemExit(main())
