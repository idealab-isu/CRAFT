# CRAFT-LAD — Run Playbook (single source of truth)

_Last updated 2026-06-03. PowerShell, from repo root `C:\Users\mohd7\craft-lad-rebuttal`, env `text2cad`._

## Every terminal, before anything

```powershell
conda activate text2cad
$env:PYTHONUTF8 = "1"     # so metric scripts can write the ↓/↑ chars in their tables
openscad --version        # MUST print a version, or all renders silently fail
```
(`OPENSCAD` on PATH and `PYTHONUTF8` are set permanently for new terminals; the lines above are a safety check.)

---

## ✅ DONE — do not repeat

- **Knowledge base built** (`build_knowledge_base.py`, 397 components + embeddings) and validated (`test_kb.py`). It was never on either machine — nothing to transfer.
- **OpenSCAD on PATH** (permanent). This was the "Render failed (unknown reason)" cause.
- **`open_clip_torch` + `fast-simplification` installed.**
- **`PYTHONUTF8=1`** set permanently (fixes the `cp1252` crash when scripts write `↓` into markdown).
- **Oversized STLs decimated** (`scripts/decimate_big_stls.py`) — pillar/screws/bearings etc. capped at 100k faces. Metric-neutral; just stops the RAM/voxel blow-up.
- **`geometric.py` patched** — `compute_voxel_iou` now runs each voxelization in a 20 s worker thread; degenerate/mis-scaled predictions (e.g. the `sheet__Cardboard` 300 mm strip) get IoU=0 instead of hanging forever. Normal samples unchanged.
- **CRAFT runs complete (with real retrieval):** NopSCADlib 445/468 (353 KB matches = 79%), ABC 88/100, Slice-100K 85/100.
- **GT + baseline STLs rendered** (all 6 baseline sets + GT NopSCADlib).
- **Geometric metrics DONE for ABC and Slice-100K** (`metrics/<ds>/summaries.json` + `chamfer/summaries.json`). These stay valid — the voxel patch only changes hanging samples, and none of theirs hung.

**In progress:** NopSCADlib `geometric.py` (running now, with all fixes).

---

## ⏭️ REMAINING — run these in order to finish

### STEP 1 — finish NopSCADlib geometric (running) → copy summaries
When the current run prints its per-method summary and exits:
```powershell
New-Item -ItemType Directory -Force -Path metrics/nopscadlib/chamfer | Out-Null
Copy-Item metrics/nopscadlib/summaries.json metrics/nopscadlib/chamfer/summaries.json -Force
```

### STEP 2 — the rest of the NopSCADlib metrics (no API)
```powershell
python experiments/03_metrics/clip/compute_clip.py --gt-png-dir ground_truth/nopscadlib/png --models craft=results/nopscadlib/craft/png gpt4o=results/nopscadlib/baselines/gpt4o/png gpt52=results/nopscadlib/baselines/gpt52/png --benchmark-json ground_truth/nopscadlib/benchmark_ground_truth.json --output-dir metrics/nopscadlib/clip
python experiments/03_metrics/fid/compute_fid.py --gt-png-dir ground_truth/nopscadlib/png --models craft=results/nopscadlib/craft/png gpt4o=results/nopscadlib/baselines/gpt4o/png gpt52=results/nopscadlib/baselines/gpt52/png --benchmark-json ground_truth/nopscadlib/benchmark_ground_truth.json --output-dir metrics/nopscadlib/fid
python experiments/03_metrics/editability/compute_editability.py --scad-dirs craft=results/nopscadlib/craft/scad gpt4o=results/nopscadlib/baselines/gpt4o/scad gpt52=results/nopscadlib/baselines/gpt52/scad --benchmark-json ground_truth/nopscadlib/benchmark_ground_truth.json --output-dir metrics/nopscadlib/editability
python experiments/05_recovery_stats/aggregate_recovery.py --dataset nopscadlib
```
(`editability` re-renders perturbed SCAD → needs OpenSCAD on PATH. `aggregate_recovery` is NopSCADlib-only; externals carry no recovery telemetry.)

### STEP 3 — refresh the chamfer copies for all 3 (safety, before tables)
```powershell
Copy-Item metrics/nopscadlib/summaries.json metrics/nopscadlib/chamfer/summaries.json -Force
Copy-Item metrics/abc/summaries.json        metrics/abc/chamfer/summaries.json        -Force
Copy-Item metrics/slice100k/summaries.json  metrics/slice100k/chamfer/summaries.json  -Force
```

### STEP 4 — significance (seconds)
```powershell
python experiments/04_statistics/bootstrap_ci.py --dataset nopscadlib
python experiments/04_statistics/bootstrap_ci.py --dataset abc
python experiments/04_statistics/bootstrap_ci.py --dataset slice100k
python experiments/04_statistics/paired_tests.py --dataset nopscadlib --reference craft
python experiments/04_statistics/paired_tests.py --dataset abc --reference craft
python experiments/04_statistics/paired_tests.py --dataset slice100k --reference craft
```

### STEP 5 — tables + checkpoint
```powershell
python experiments/06_tables_and_figures/generate_all_tables.py --all
git add -A
git commit -m "KB re-run complete: CRAFT + externals + fresh metrics + tables (voxel-timeout + decimation fixes)"
git push
```
**✔ Final check:** open the tables; the geometric columns (Tables II / IV / V) must be **populated**. Blank = the `chamfer/` copy didn't run → redo Step 3 and regenerate.

---

## Where each table reads from

| Table | Source file |
|---|---|
| I — CLIP + FID | `metrics/nopscadlib/clip/clip_detailed_results.json`, `metrics/nopscadlib/fid/fid_results.json` |
| II / IV / V — CD·F1·IoU | `metrics/<ds>/chamfer/summaries.json` |
| III — ablation | `metrics/nopscadlib/chamfer/summaries.json` |
| VI — recovery | `metrics/nopscadlib/recovery/per_layer_stats.json` |
| VII — matched-effort | `metrics/nopscadlib/chamfer/summaries.json` |
| VIII — editability | `metrics/nopscadlib/editability/editability_summaries.json` |

## Gotchas we hit (so they don't bite again)

1. **OpenSCAD off PATH** → silent "Render failed (unknown reason)". Always `openscad --version` first.
2. **`cp1252` Unicode crash** writing markdown tables → set `PYTHONUTF8=1`. (The JSON is written before the markdown, so even when it crashed the data was saved — but set it anyway.)
3. **Geometric output dir**: scripts write `summaries.json` to `--output-dir`; the table generator reads it from a `chamfer/` subfolder → always `Copy-Item` after.
4. **External baselines** live at `results/<ds>/baselines/<model>/stl`, which the purpose-built external evaluator can't discover → use the shared `geometric.py` with explicit `name=dir` pairs and `--gt-dir data/<ds>`.
5. **Over-tessellated meshes** (e.g. pillar = 1M faces / 303 MB) → `decimate_big_stls.py` (metric-neutral).
6. **trimesh voxelizer infinite-loops** on degenerate/mis-scaled meshes → already patched with a 20 s timeout in `compute_voxel_iou`.

---

## Still pending — separate, later effort (after A–D is committed)

**Ablation sweep (Table III)** and **matched-effort baselines (Table VII)**: 5 + 3 variants × 468.
For each variant, after its generation run:
1. Render its STLs (`render_craft_stls.py --scad-dir results/nopscadlib/ablations/<v>/scad --stl-dir results/nopscadlib/ablations/<v>/stl --workers 8 --skip-existing`).
2. `decimate_big_stls.py` (add the variant's stl dir, or it already scans `results/**`) — same policy as the main run.
3. Compute geometric for **all variants + craft in ONE `geometric.py` call** (multiple `name=dir` pairs) into `metrics/nopscadlib`, then `Copy-Item` summaries → `chamfer/`. One combined file = all rows present (a fresh per-variant run would overwrite it).
4. `direct_matched_calls`: set `--matched-calls` to CRAFT's mean LLM-call count first:
   `python -c "import json; rs=json.load(open('results/nopscadlib/craft/results.json'))['results']; c=[r.get('recovery_budget',{}).get('used',0)+3 for r in rs if r.get('success')]; print(round(sum(c)/len(c),1))"`

The `geometric.py` voxel-timeout patch and the decimation policy apply to these variants too — keep them on, uniformly.
