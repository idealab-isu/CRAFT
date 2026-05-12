"""Per-method runners.

Each runner consumes a sample directory in the layout produced by
`fetch_ztc_test.py` (or an analogous ABC fetcher) and writes outputs into
`results/zerotocad_eval/{benchmark}/{method}/{uuid}/`.

Methods:
    run_craft         - CRAFT v3 image-only, our headline method
    run_gpt5_baseline - GPT-5.2 zero-shot, CadQuery or OpenSCAD output
    run_their_qwen    - ADSKAILab/Zero-To-CAD-Qwen3-VL-2B (fine-tuned)
"""
