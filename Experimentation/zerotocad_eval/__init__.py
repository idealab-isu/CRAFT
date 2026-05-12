"""Zero-to-CAD evaluation harness for CRAFT v3.

This package replicates the evaluation protocol of Ataei et al. (Autodesk
Research, arXiv:2604.24479, April 2026) so CRAFT v3 can be benchmarked
side-by-side against their fine-tuned Qwen3-VL-2B and the GPT-5.2 zero-shot
baselines they publish.

Submodules (in build order):
  fetch_ztc_test  - stream the 10K ZTC test split → per-sample folders
  voxel_iou.score - voxel-IoU @ 64^3 with 24-cube-rotation alignment
  cd.score        - aligned Chamfer Distance cross-check
  run_craft       - run CRAFTPipeline.run_vision on the 8-view input
  run_baselines   - GPT-5.2 zero-shot + their fine-tuned Qwen

See CRAFT_zerotocad_eval_plan.md (repo root) for the full plan.
"""
