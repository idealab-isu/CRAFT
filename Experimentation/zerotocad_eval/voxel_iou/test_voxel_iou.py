"""Sanity tests for the voxel-IoU scorer.

Run as a standalone script:

    python -m Experimentation.zerotocad_eval.voxel_iou.test_voxel_iou

All four checks must pass before any model output is trusted:

    1. IoU(GT, GT) == 1.0                   identity sanity
    2. IoU(GT, 90deg-rotated GT) == 1.0     24-cube-rotation alignment works
    3. IoU(GT, 2x-scaled GT) == 1.0         normalization works
    4. IoU(cube, sphere) in (0.45, 0.60)    discriminates clearly different shapes
"""

from __future__ import annotations

import math
import sys
from pathlib import Path

import numpy as np


_REPO_ROOT = Path(__file__).resolve().parents[3]
_DATA_DIR = _REPO_ROOT / "Experimentation" / "zerotocad_eval" / "data" / "ztc_test"


def _import_trimesh():
    try:
        import trimesh  # noqa: F401
        return trimesh
    except ImportError:
        sys.stderr.write(
            "Missing 'trimesh'. Install with: pip install trimesh\n"
        )
        sys.exit(1)


def _pick_test_stl() -> Path:
    """Pick any fetched ZTC sample's gt.stl. Fall back to a generated cube."""
    if _DATA_DIR.exists():
        for uuid_dir in sorted(_DATA_DIR.iterdir()):
            stl = uuid_dir / "gt.stl"
            if stl.exists():
                return stl
    raise FileNotFoundError(
        f"No samples in {_DATA_DIR}. Run `python -m "
        "Experimentation.zerotocad_eval.fetch_ztc_test --limit 5` first."
    )


def _print_result(name: str, passed: bool, detail: str) -> None:
    mark = "PASS" if passed else "FAIL"
    print(f"[{mark}] {name:48s}  {detail}")


def test_identity(score_pair):
    """IoU of a mesh with itself should be 1.0 exactly."""
    stl = _pick_test_stl()
    res = score_pair(stl, stl)
    passed = res is not None and abs(res.iou - 1.0) < 1e-6
    _print_result("IoU(GT, GT) == 1.0", passed, f"iou={res.iou:.6f}")
    return passed


def test_rotated(score_pair):
    """IoU of a 90-deg-rotated mesh vs. itself should be ~1.0 after 24-rotation alignment.

    Rotating by 90 about the z axis is one of the 24 cube rotations, so the
    aligned IoU MUST be exactly 1.0 (modulo voxelization edge artifacts).
    """
    import tempfile
    import trimesh

    stl = _pick_test_stl()
    mesh = trimesh.load(str(stl), force="mesh")

    rot = trimesh.transformations.rotation_matrix(angle=math.pi / 2, direction=[0, 0, 1])
    mesh_rot = mesh.copy()
    mesh_rot.apply_transform(rot)

    with tempfile.NamedTemporaryFile(suffix=".stl", delete=False) as tf:
        rotated_path = tf.name
    mesh_rot.export(rotated_path, file_type="stl")
    try:
        res = score_pair(rotated_path, stl)
    finally:
        Path(rotated_path).unlink(missing_ok=True)

    passed = res is not None and res.iou > 0.95
    _print_result("IoU(GT, 90deg-rotated GT) >= 0.95", passed, f"iou={res.iou:.6f}")
    return passed


def test_scaled(score_pair):
    """IoU should be invariant to uniform scale (normalize cancels it)."""
    import tempfile
    import trimesh

    stl = _pick_test_stl()
    mesh = trimesh.load(str(stl), force="mesh")
    mesh_scaled = mesh.copy()
    mesh_scaled.apply_scale(2.0)

    with tempfile.NamedTemporaryFile(suffix=".stl", delete=False) as tf:
        scaled_path = tf.name
    mesh_scaled.export(scaled_path, file_type="stl")
    try:
        res = score_pair(scaled_path, stl)
    finally:
        Path(scaled_path).unlink(missing_ok=True)

    passed = res is not None and res.iou > 0.95
    _print_result("IoU(GT, 2x-scaled GT) >= 0.95", passed, f"iou={res.iou:.6f}")
    return passed


def test_cube_vs_sphere(score_pair):
    """Cube vs. sphere of similar size should yield a moderate IoU.

    A unit-cube and an inscribed sphere have IoU ~ pi/6 ~ 0.52. After
    normalization (longest extent = 1.0), the inscribed sphere fills less of
    the cube's volume than a circumscribed sphere would, so we expect IoU in
    roughly the 0.45-0.60 band.
    """
    import tempfile
    import trimesh

    cube = trimesh.creation.box(extents=[1.0, 1.0, 1.0])
    sphere = trimesh.creation.icosphere(subdivisions=4, radius=0.5)

    with tempfile.NamedTemporaryFile(suffix=".stl", delete=False) as tc, \
         tempfile.NamedTemporaryFile(suffix=".stl", delete=False) as ts:
        cube_path = tc.name
        sphere_path = ts.name
    cube.export(cube_path, file_type="stl")
    sphere.export(sphere_path, file_type="stl")
    try:
        res = score_pair(cube_path, sphere_path)
    finally:
        Path(cube_path).unlink(missing_ok=True)
        Path(sphere_path).unlink(missing_ok=True)

    passed = res is not None and 0.40 < res.iou < 0.70
    _print_result("IoU(cube, sphere) in (0.40, 0.70)", passed, f"iou={res.iou:.6f}")
    return passed


def main() -> int:
    _import_trimesh()
    from .score import score_stl_pair

    print("Voxel-IoU sanity tests (resolution=64, 24 cube rotations)")
    print("=" * 70)
    results = [
        test_identity(score_stl_pair),
        test_rotated(score_stl_pair),
        test_scaled(score_stl_pair),
        test_cube_vs_sphere(score_stl_pair),
    ]
    print("=" * 70)
    n_pass = sum(results)
    print(f"{n_pass}/{len(results)} checks passed.")
    return 0 if n_pass == len(results) else 1


if __name__ == "__main__":
    raise SystemExit(main())
