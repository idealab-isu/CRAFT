#!/usr/bin/env python3
"""
Shrink pathologically over-tessellated STLs so the geometric metric can process them.
A few generated SCAD files produce runaway meshes (100s of MB) that OOM the voxel-IoU
step. Decimating to ~100k faces preserves the surface (CD/F1/IoU unchanged in practice)
but makes them loadable. STLs are regenerable, so in-place overwrite is safe.

Run once before geometric.py:
    pip install fast-simplification
    python scripts/decimate_big_stls.py
"""
import os, glob, sys
import trimesh

THRESHOLD_MB = 10        # only touch files bigger than this
TARGET_FACES = 100_000   # plenty for these small components

# Auto-discover every STL output dir — craft, baselines, ablations, matched_effort —
# plus the NopSCADlib ground truth. New variant dirs are picked up automatically.
STL_DIRS = sorted(set(
    glob.glob("results/*/stl")
    + glob.glob("results/*/*/stl")
    + glob.glob("results/*/*/*/stl")
    + ["ground_truth/nopscadlib/stl"]
))

def decimate(mesh, target):
    # try trimesh's built-in (uses fast_simplification if installed)
    try:
        return mesh.simplify_quadric_decimation(face_count=target)
    except TypeError:
        try:
            return mesh.simplify_quadric_decimation(target)
        except Exception:
            pass
    except Exception:
        pass
    # direct fast_simplification fallback
    import fast_simplification
    v, f = fast_simplification.simplify(mesh.vertices, mesh.faces, target_count=target)
    return trimesh.Trimesh(vertices=v, faces=f, process=False)

def main():
    touched = 0
    for d in STL_DIRS:
        if not os.path.isdir(d):
            continue
        for path in glob.glob(os.path.join(d, "*.stl")):
            mb = os.path.getsize(path) / 1048576
            if mb < THRESHOLD_MB:
                continue
            try:
                m = trimesh.load(path, force="mesh")
                nf = len(m.faces)
                if nf <= TARGET_FACES:
                    print(f"  skip (faces ok)  {mb:6.0f}MB  {os.path.basename(path)}")
                    continue
                m2 = decimate(m, TARGET_FACES)
                m2.export(path)
                newmb = os.path.getsize(path) / 1048576
                print(f"  DECIMATED        {mb:6.0f}->{newmb:5.1f}MB  {nf}->{len(m2.faces)} faces  {os.path.basename(path)}")
                touched += 1
            except Exception as e:
                print(f"  !! FAILED {os.path.basename(path)}: {e.__class__.__name__}: {e}")
    print(f"\nDone. Decimated {touched} oversized STL(s). Now re-run geometric.py.")

if __name__ == "__main__":
    sys.exit(main())
