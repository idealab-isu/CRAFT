"""Shared helpers for per-method runners."""

from __future__ import annotations

import json
import os
import shutil
import subprocess
import sys
import tempfile
import time
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Dict, List, Optional


REPO_ROOT = Path(__file__).resolve().parents[3]


@dataclass
class SampleDirs:
    """Resolved per-sample input/output paths."""

    uuid: str
    sample_dir: Path           # data/zerotocad_eval/{benchmark}/{uuid}/
    view_paths: List[Path]     # 8 view PNGs (sample_dir/views/view_0..7.png)
    gt_stl: Path
    method_out_dir: Path       # results/.../{method}/{uuid}/


def iter_sample_dirs(
    data_root: Path,
    method_root: Path,
    limit: Optional[int] = None,
    skip_existing: bool = True,
) -> List[SampleDirs]:
    """List all (sample, method-output) pairs to process.

    `skip_existing` drops samples whose method_out_dir already has output.stl
    AND metrics.json — those have already been scored.
    """
    out: List[SampleDirs] = []
    if not data_root.exists():
        raise FileNotFoundError(f"Data root does not exist: {data_root}")

    for uuid_dir in sorted(data_root.iterdir()):
        if not uuid_dir.is_dir():
            continue
        views_dir = uuid_dir / "views"
        if not views_dir.is_dir():
            continue
        view_paths = [views_dir / f"view_{i}.png" for i in range(8)]
        if not all(p.exists() for p in view_paths):
            continue

        gt_stl = uuid_dir / "gt.stl"
        method_out = method_root / uuid_dir.name

        # Resume logic: a sample is "already attempted" once the runner has
        # written its audit.json — regardless of whether output.stl was
        # produced. Failures count as Success=0 / IoU=0 (plan §12) rather
        # than as retries, so we don't burn another API call on a known-bad
        # sample. Pass --force on the runner CLI to override and redo
        # everything.
        if skip_existing and (method_out / "audit.json").exists():
            continue

        out.append(
            SampleDirs(
                uuid=uuid_dir.name,
                sample_dir=uuid_dir,
                view_paths=view_paths,
                gt_stl=gt_stl,
                method_out_dir=method_out,
            )
        )

        if limit is not None and len(out) >= limit:
            break

    return out


# ---------------------------------------------------------------------------
# Code → STL execution
# ---------------------------------------------------------------------------


def openscad_to_stl(scad_code: str, stl_out: Path, timeout_s: int = 120) -> Optional[Path]:
    """Run OpenSCAD on a temp .scad file and export to STL. Returns path on success."""
    stl_out.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(suffix=".scad", delete=False, mode="w") as tf:
        tf.write(scad_code)
        scad_path = tf.name
    try:
        cmd = ["openscad", "-o", str(stl_out), scad_path]
        result = subprocess.run(
            cmd, capture_output=True, text=True, timeout=timeout_s
        )
        if result.returncode != 0 or not stl_out.exists() or stl_out.stat().st_size == 0:
            return None
        return stl_out
    except (subprocess.TimeoutExpired, FileNotFoundError):
        return None
    finally:
        try:
            os.unlink(scad_path)
        except OSError:
            pass


def cadquery_to_stl(code: str, stl_out: Path) -> Optional[Path]:
    """Execute CadQuery code and export the resulting solid to STL.

    Looks for a variable named `result` (Z2C convention), falling back to
    `solid`, `model`, `part`, `shape` in that order. Returns None if
    execution fails or no solid is found.

    Note: this `exec`s arbitrary code. For benchmark use only — never run
    on untrusted prompts in production.
    """
    try:
        import cadquery as cq
    except ImportError:
        sys.stderr.write(
            "cadquery is not installed. Install with: "
            "`pip install cadquery` (or `mamba install -c conda-forge cadquery`).\n"
        )
        return None

    stl_out.parent.mkdir(parents=True, exist_ok=True)
    namespace: Dict[str, Any] = {"cq": cq, "cadquery": cq}
    try:
        exec(code, namespace)  # noqa: S102 — required for benchmark
    except Exception as e:
        sys.stderr.write(f"[cadquery exec] {type(e).__name__}: {e}\n")
        return None

    candidate = namespace.get("result")
    if candidate is None:
        for name in ("solid", "model", "part", "shape"):
            if name in namespace and not isinstance(namespace[name], type):
                candidate = namespace[name]
                break
    if candidate is None:
        return None

    try:
        cq.exporters.export(candidate, str(stl_out))
    except Exception as e:
        sys.stderr.write(f"[cadquery export] {type(e).__name__}: {e}\n")
        return None

    return stl_out if (stl_out.exists() and stl_out.stat().st_size > 0) else None


# ---------------------------------------------------------------------------
# Audit logging
# ---------------------------------------------------------------------------


@dataclass
class RunAudit:
    method: str
    uuid: str
    output_lang: str           # "openscad" | "cadquery"
    success_code: bool         # generation produced non-empty source
    success_stl: bool          # source executed and produced an STL
    error: Optional[str] = None
    timing_seconds: Dict[str, float] = field(default_factory=dict)
    extra: Dict[str, Any] = field(default_factory=dict)

    def write(self, out_dir: Path) -> None:
        out_dir.mkdir(parents=True, exist_ok=True)
        path = out_dir / "audit.json"
        path.write_text(json.dumps(self.__dict__, indent=2, default=str))


def stopwatch():
    """Return a callable that returns elapsed-seconds since the previous call."""
    t = [time.time()]

    def lap() -> float:
        now = time.time()
        delta = now - t[0]
        t[0] = now
        return delta

    return lap
