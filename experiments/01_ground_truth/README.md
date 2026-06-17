# Phase 01 — Ground Truth Construction

Builds the ground-truth assets that every later phase reads.

## What this phase produces

| Dataset | Output | Contents |
|---|---|---|
| NopSCADlib | `ground_truth/nopscadlib/scad/<id>.scad` | Reference SCAD files extracted from NopSCADlib catalog |
| NopSCADlib | `ground_truth/nopscadlib/stl/<id>.stl` | Reference STL meshes rendered from the SCADs |
| NopSCADlib | `ground_truth/nopscadlib/png/<id>.png` | Six-view orthographic PNG renders |
| NopSCADlib | `ground_truth/nopscadlib/benchmark_ground_truth.json` | Master metadata file: per-component prompts, expected parts, tiers, complexity scores |
| ABC, Slice-100K | `ground_truth/<dataset>/{stl,png}/` | Same per-component renders |
| ABC, Slice-100K | `ground_truth/<dataset>/<dataset>_ground_truth.json` | GPT-generated prompts + mesh stats + tiers |

## Scripts

| Script | Dataset | Purpose |
|---|---|---|
| `render_nopscadlib.py` | NopSCADlib | Walks the NopSCADlib catalog, renders each component into SCAD/STL/PNG |
| `compute_complexity.py` | NopSCADlib | Parses each NopSCADlib module to compute a complexity score (primitive count, CSG depth, parameter count, etc.); assigns Simple/Medium/Complex tiers at the 33rd/66th percentiles |
| `nopscadlib_gt.py` | NopSCADlib | Catalog walker / metadata extractor |
| `external_render_views.py` | ABC, Slice-100K | Renders six orthographic views per STL |
| `external_gt.py` | ABC, Slice-100K | Uses GPT-4o vision to generate three prompt variants per component + mesh statistics + tiers |

## How tiering works (Simple / Medium / Complex)

For NopSCADlib (`compute_complexity.py`):

    complexity_score =  1.0 · primitive_count
                     +  1.5 · boolean_op_count
                     +  0.5 · csg_depth
                     +  0.3 · parameter_count
                     +  2.0 · sub_module_calls
                     +  0.05 · lines_of_code
                     +  0.3 · transform_count

Components are sorted by `complexity_score` and split at the 33rd and 66th
percentiles into Simple / Medium / Complex (yielding 159 / 160 / 149 in the
NopSCADlib set of 468).

For ABC and Slice-100K, tiers are derived from mesh statistics (vertex count,
face count, surface area, bbox volume) in `external_gt.py`.

## Reproducing

```bash
# NopSCADlib (assumes you've already cloned NopSCADlib into pipeline/kb_data/)
python experiments/01_ground_truth/render_nopscadlib.py
python experiments/01_ground_truth/compute_complexity.py

# External datasets
python experiments/01_ground_truth/external_render_views.py --dataset abc --stl-dir data/abc
python experiments/01_ground_truth/external_gt.py --dataset abc

python experiments/01_ground_truth/external_render_views.py --dataset slice100k --stl-dir data/slice100k
python experiments/01_ground_truth/external_gt.py --dataset slice100k
```
