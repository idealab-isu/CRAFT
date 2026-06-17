#!/usr/bin/env python3
"""CRAFT-LAD — lab-PC readiness check. Run in the text2cad env:  python scripts/pc_check.py"""
import importlib, os, json, glob

print("="*64)
print("DEPENDENCY CHECK (text2cad env)")
print("="*64)
MODS = {
    "chromadb":     "KB vector store (Step 0 / run_craft retrieval)",
    "openai":       "LLM + text embeddings",
    "dotenv":       "python-dotenv (.env)",
    "numpy":        "everything",
    "PIL":          "Pillow image IO",
    "jsonschema":   "pipeline JSON-IR schema",
    "trimesh":      "geometric metrics: CD / F1 / Voxel IoU",
    "scipy":        "geometric + FID",
    "torch":        "CLIP + FID + LPIPS",
    "torchvision":  "FID Inception features",
    "open_clip":    "CLIP score (pip: open_clip_torch)",
    "lpips":        "LPIPS (supplementary table only)",
}
missing = []
for m, why in MODS.items():
    try:
        importlib.import_module(m)
        print(f"  OK    {m:13} - {why}")
    except Exception as e:
        print(f"  MISS  {m:13} - {why}   [{e.__class__.__name__}]")
        missing.append(m)

print()
try:
    import chromadb
    print("chromadb version:", chromadb.__version__, "(must match the Mac's to reuse its vector store)")
except Exception:
    print("chromadb: not importable")

print("\n" + "="*64)
print("KNOWLEDGE BASE STATE (pipeline/kb_data)")
print("="*64)
kb = "pipeline/kb_data"
for item in ["chroma_db", "reference_images", "documentation.json", "component_index.json", "nopscadlib"]:
    p = os.path.join(kb, item)
    if os.path.exists(p):
        n = sum(len(files) for _, _, files in os.walk(p)) if os.path.isdir(p) else 1
        print(f"  PRESENT  {item:22} ({n} files)")
    else:
        print(f"  MISSING  {item}")

print("\n" + "="*64)
print("CRAFT RESULTS — did retrieval fire?")
print("="*64)
rp = "results/nopscadlib/craft/results.json"
if os.path.exists(rp):
    rs = json.load(open(rp)).get("results", [])
    ok = [r for r in rs if r.get("success")]
    m = sum(1 for r in ok if r.get("kb_component_matched"))
    print(f"  success={len(ok)}  KB matches={m}/{len(ok)}  ->",
          "NO-RETRIEVAL (re-run after KB works)" if m == 0 else "retrieval active")
else:
    print("  no results.json yet")

print("\n" + "="*64)
print("RESULT / METRIC FILE COUNTS")
print("="*64)
def c(p): return len(glob.glob(p))
for ds in ["nopscadlib", "abc", "slice100k"]:
    for meth in (["craft", "baselines/gpt4o", "baselines/gpt52"]):
        base = f"results/{ds}/{meth}"
        if os.path.isdir(base):
            print(f"  {ds}/{meth:16} scad={c(base+'/scad/*.scad'):3}  stl={c(base+'/stl/*.stl'):3}  png={c(base+'/png/*.png'):3}")

print("\nMissing deps:", missing if missing else "none — env looks complete")
