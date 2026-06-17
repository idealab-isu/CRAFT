#!/usr/bin/env python3
"""
CLIP Score Evaluation for Text2CAD SPM 2026

Measures text-image semantic alignment using CLIP cosine similarity.
Unlike geometric metrics (CD, F1, VoxIoU), CLIP Score answers:
  "Does the generated CAD render look like what the text prompt described?"

This is a per-sample metric that does NOT require ground truth — it directly
measures how well the model understood the text description.

Usage:
    # Evaluate GT renders (ceiling reference)
    python evaluate_clip_score.py \
        --gt-png-dir ground_truth/png

    # Evaluate a single model
    python evaluate_clip_score.py \
        --gt-png-dir ground_truth/png \
        --pred-png-dir results/craft/png \
        --model-name craft

    # Evaluate all models at once
    python evaluate_clip_score.py \
        --gt-png-dir ground_truth/png \
        --models craft=results/craft/png \
                 gpt4o=results/gpt4o/png \
                 gpt52=results/gpt52/png

    # Use a different CLIP backbone
    python evaluate_clip_score.py \
        --gt-png-dir ground_truth/png \
        --clip-model ViT-B-32 \
        --pretrained openai

Requirements:
    pip install open_clip_torch torch pillow numpy

How CLIP Score works:
    1. Text prompt → CLIP text encoder → 512/768-dim embedding
    2. Rendered PNG → CLIP image encoder → 512/768-dim embedding
    3. Score = cosine_similarity(text_embedding, image_embedding)

    CLIP (Contrastive Language-Image Pre-training) was trained on 400M
    image-text pairs. Both encoders map inputs to the same embedding space
    where matching (text, image) pairs have high cosine similarity.

    Typical score ranges for specialized domains: 0.15-0.35
    Higher is better. GT renders provide an upper-bound reference.
"""

import os
import sys
import json
import argparse
import time
import logging
from pathlib import Path
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass, field, asdict
from datetime import datetime

import numpy as np

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(message)s',
    datefmt='%H:%M:%S'
)
logger = logging.getLogger(__name__)

SCRIPT_DIR = Path(__file__).parent


# =============================================================================
# DATA STRUCTURES
# =============================================================================

@dataclass
class CLIPResult:
    """CLIP Score for a single prompt-image pair."""
    prompt_id: str
    source: str          # "gt", "craft", "gpt4o", etc.
    prompt_text: str
    clip_score: float = float('nan')   # Cosine similarity (higher is better)
    tier: str = ""
    family: str = ""
    png_exists: bool = False
    error: str = ""


@dataclass
class CLIPSummary:
    """Aggregated CLIP Scores for one source (GT or model)."""
    source_name: str
    clip_model: str = ""
    n_evaluated: int = 0
    n_skipped: int = 0
    # Overall
    clip_mean: float = float('nan')
    clip_std: float = float('nan')
    clip_median: float = float('nan')
    clip_min: float = float('nan')
    clip_max: float = float('nan')
    # Per-tier
    clip_by_tier: Dict[str, float] = field(default_factory=dict)
    clip_std_by_tier: Dict[str, float] = field(default_factory=dict)
    clip_count_by_tier: Dict[str, int] = field(default_factory=dict)


# =============================================================================
# CLIP MODEL LOADER
# =============================================================================

def load_clip_model(model_name: str = "ViT-L-14", pretrained: str = "openai",
                    device: str = "auto"):
    """
    Load CLIP model and preprocessing transforms.

    Args:
        model_name: CLIP architecture (e.g., "ViT-L-14", "ViT-B-32")
        pretrained: Pretrained weights source (e.g., "openai", "laion2b_s32b_b82k")
        device: "auto" | "cuda" | "cpu"

    Returns:
        (model, preprocess, tokenizer, device)
    """
    try:
        import torch
        import open_clip
    except ImportError:
        logger.error(
            "Required packages not found. Install with:\n"
            "  pip install open_clip_torch torch pillow numpy"
        )
        sys.exit(1)

    if device == "auto":
        device = "cuda" if torch.cuda.is_available() else "cpu"

    logger.info(f"Loading CLIP model: {model_name} (pretrained={pretrained}) on {device}")
    model, _, preprocess = open_clip.create_model_and_transforms(
        model_name, pretrained=pretrained, device=device
    )
    tokenizer = open_clip.get_tokenizer(model_name)
    model.eval()

    logger.info(f"CLIP model loaded successfully")
    return model, preprocess, tokenizer, device


# =============================================================================
# CLIP SCORE COMPUTATION
# =============================================================================

def compute_clip_scores_batch(
    prompts: List[str],
    image_paths: List[str],
    model, preprocess, tokenizer, device: str,
    batch_size: int = 32
) -> List[float]:
    """
    Compute CLIP cosine similarity for a batch of (text, image) pairs.

    This is the core computation:
      1. Each text prompt is tokenized and passed through CLIP's text encoder
         to produce a normalized embedding vector.
      2. Each PNG image is preprocessed (resized, center-cropped, normalized)
         and passed through CLIP's image encoder to produce a normalized
         embedding vector.
      3. The cosine similarity between each (text, image) pair is computed.
         Since both embeddings are L2-normalized, this is just the dot product.

    Args:
        prompts: List of text prompts
        image_paths: List of PNG file paths (same length as prompts)
        model: CLIP model
        preprocess: Image preprocessing transform
        tokenizer: Text tokenizer
        device: "cuda" or "cpu"
        batch_size: Number of pairs to process at once

    Returns:
        List of cosine similarity scores (same length as inputs)
    """
    import torch
    from PIL import Image

    scores = []

    for batch_start in range(0, len(prompts), batch_size):
        batch_end = min(batch_start + batch_size, len(prompts))
        batch_prompts = prompts[batch_start:batch_end]
        batch_paths = image_paths[batch_start:batch_end]

        # Load and preprocess images
        images = []
        valid_indices = []
        for i, img_path in enumerate(batch_paths):
            try:
                img = Image.open(img_path).convert("RGB")
                images.append(preprocess(img))
                valid_indices.append(i)
            except Exception as e:
                logger.warning(f"Failed to load image {img_path}: {e}")

        if not images:
            scores.extend([float('nan')] * (batch_end - batch_start))
            continue

        # Stack images into a batch tensor
        image_tensor = torch.stack(images).to(device)

        # Tokenize text prompts (only for valid images)
        valid_prompts = [batch_prompts[i] for i in valid_indices]
        text_tokens = tokenizer(valid_prompts).to(device)

        # Forward pass through CLIP
        with torch.no_grad():
            # Encode images → normalized embeddings
            image_features = model.encode_image(image_tensor)
            image_features = image_features / image_features.norm(dim=-1, keepdim=True)

            # Encode text → normalized embeddings
            text_features = model.encode_text(text_tokens)
            text_features = text_features / text_features.norm(dim=-1, keepdim=True)

            # Cosine similarity = dot product of normalized vectors
            # We compute per-pair similarity (not the full NxN matrix)
            similarities = (image_features * text_features).sum(dim=-1)
            similarities = similarities.cpu().numpy()

        # Map back to original indices (fill NaN for failed images)
        batch_scores = [float('nan')] * (batch_end - batch_start)
        for idx, valid_idx in enumerate(valid_indices):
            batch_scores[valid_idx] = float(similarities[idx])

        scores.extend(batch_scores)

    return scores


# =============================================================================
# EVALUATION PIPELINE
# =============================================================================

def load_benchmark_metadata(benchmark_json: str) -> List[dict]:
    """Load component metadata from benchmark_ground_truth.json."""
    with open(benchmark_json) as f:
        data = json.load(f)

    components = data.get("components", [])
    logger.info(f"Loaded {len(components)} components from {benchmark_json}")
    return components


def evaluate_source(
    components: List[dict],
    png_dir: str,
    source_name: str,
    model, preprocess, tokenizer, device: str,
    prompt_ids: Optional[List[str]] = None,
    batch_size: int = 32
) -> Tuple[List[CLIPResult], CLIPSummary]:
    """
    Evaluate CLIP Scores for one source (GT or a model).

    Args:
        components: List of component metadata dicts
        png_dir: Directory containing rendered PNGs
        source_name: "gt", "craft", "gpt4o", etc.
        model, preprocess, tokenizer, device: CLIP model components
        prompt_ids: Optional subset of IDs to evaluate
        batch_size: Batch size for CLIP inference

    Returns:
        (list of CLIPResult, CLIPSummary)
    """
    logger.info(f"Evaluating CLIP Scores for: {source_name} (png_dir={png_dir})")

    # Filter components if prompt_ids specified
    if prompt_ids:
        id_set = set(prompt_ids)
        components = [c for c in components if c["id"] in id_set]

    # Collect valid (prompt, image_path) pairs
    valid_prompts = []
    valid_paths = []
    valid_components = []
    skipped = []

    for comp in components:
        comp_id = comp["id"]
        prompt_text = comp.get("prompt", "")
        png_path = os.path.join(png_dir, f"{comp_id}.png")

        if not prompt_text:
            skipped.append((comp_id, "no prompt text"))
            continue
        if not os.path.exists(png_path):
            skipped.append((comp_id, "png not found"))
            continue

        valid_prompts.append(prompt_text)
        valid_paths.append(png_path)
        valid_components.append(comp)

    if skipped:
        logger.info(f"  Skipped {len(skipped)} components (no PNG or no prompt)")

    if not valid_prompts:
        logger.warning(f"  No valid (prompt, image) pairs found for {source_name}")
        return [], CLIPSummary(source_name=source_name)

    logger.info(f"  Computing CLIP Scores for {len(valid_prompts)} samples...")

    # Compute scores in batches
    t0 = time.time()
    scores = compute_clip_scores_batch(
        valid_prompts, valid_paths, model, preprocess, tokenizer, device,
        batch_size=batch_size
    )
    elapsed = time.time() - t0
    logger.info(f"  Done in {elapsed:.1f}s ({len(valid_prompts)/max(elapsed,0.001):.0f} samples/sec)")

    # Build per-sample results
    results = []
    for comp, score in zip(valid_components, scores):
        results.append(CLIPResult(
            prompt_id=comp["id"],
            source=source_name,
            prompt_text=comp.get("prompt", ""),
            clip_score=score,
            tier=comp.get("tier", ""),
            family=comp.get("component_family", ""),
            png_exists=True,
        ))

    # Add skipped components
    for comp_id, reason in skipped:
        comp = next((c for c in components if c["id"] == comp_id), None)
        if comp:
            results.append(CLIPResult(
                prompt_id=comp_id,
                source=source_name,
                prompt_text=comp.get("prompt", ""),
                tier=comp.get("tier", ""),
                family=comp.get("component_family", ""),
                png_exists=False,
                error=reason,
            ))

    # Compute summary
    summary = _compute_summary(results, source_name)
    return results, summary


def _compute_summary(results: List[CLIPResult], source_name: str) -> CLIPSummary:
    """Compute aggregated summary from individual results."""
    summary = CLIPSummary(source_name=source_name)

    valid = [r for r in results if not r.error and np.isfinite(r.clip_score)]
    summary.n_evaluated = len(valid)
    summary.n_skipped = len(results) - len(valid)

    if not valid:
        return summary

    scores = [r.clip_score for r in valid]
    summary.clip_mean = float(np.mean(scores))
    summary.clip_std = float(np.std(scores))
    summary.clip_median = float(np.median(scores))
    summary.clip_min = float(np.min(scores))
    summary.clip_max = float(np.max(scores))

    # Per-tier
    for tier in ["Simple", "Medium", "Complex"]:
        tier_scores = [r.clip_score for r in valid if r.tier == tier]
        if tier_scores:
            summary.clip_by_tier[tier] = float(np.mean(tier_scores))
            summary.clip_std_by_tier[tier] = float(np.std(tier_scores))
            summary.clip_count_by_tier[tier] = len(tier_scores)

    return summary


# =============================================================================
# OUTPUT FORMATTERS
# =============================================================================

def save_results(
    all_results: Dict[str, List[CLIPResult]],
    all_summaries: Dict[str, CLIPSummary],
    output_dir: str,
    clip_model_name: str
):
    """Save evaluation results to JSON and markdown."""
    out_path = Path(output_dir)
    out_path.mkdir(parents=True, exist_ok=True)

    # Save detailed results as JSON
    detailed = {}
    for source_name, results in all_results.items():
        detailed[source_name] = [asdict(r) for r in results]

    with open(out_path / "clip_detailed_results.json", 'w') as f:
        json.dump(detailed, f, indent=2, default=str)

    # Save summaries as JSON
    summaries_data = {name: asdict(s) for name, s in all_summaries.items()}
    with open(out_path / "clip_summaries.json", 'w') as f:
        json.dump(summaries_data, f, indent=2, default=str)

    # Generate markdown table
    _generate_markdown_table(all_summaries, all_results, out_path, clip_model_name)

    # Generate CSV for easy import
    _generate_csv(all_results, out_path)

    logger.info(f"Results saved to {out_path}")


def _generate_csv(all_results: Dict[str, List[CLIPResult]], out_path: Path):
    """Generate CSV with per-sample scores for all sources side by side."""
    # Collect all prompt IDs
    all_ids = set()
    for results in all_results.values():
        for r in results:
            all_ids.add(r.prompt_id)

    # Build lookup: source -> prompt_id -> score
    lookups = {}
    prompt_texts = {}
    tiers = {}
    families = {}
    for source_name, results in all_results.items():
        lookups[source_name] = {}
        for r in results:
            lookups[source_name][r.prompt_id] = r.clip_score
            prompt_texts[r.prompt_id] = r.prompt_text
            tiers[r.prompt_id] = r.tier
            families[r.prompt_id] = r.family

    sources = sorted(all_results.keys())
    sorted_ids = sorted(all_ids)

    lines = ["prompt_id,tier,family,prompt_text," + ",".join(f"clip_{s}" for s in sources)]
    for pid in sorted_ids:
        prompt = prompt_texts.get(pid, "").replace(",", ";")  # escape commas
        tier = tiers.get(pid, "")
        family = families.get(pid, "")
        scores = []
        for s in sources:
            val = lookups[s].get(pid, float('nan'))
            scores.append(f"{val:.6f}" if np.isfinite(val) else "")
        lines.append(f"{pid},{tier},{family},{prompt},{','.join(scores)}")

    with open(out_path / "clip_scores.csv", 'w') as f:
        f.write("\n".join(lines))


def _generate_markdown_table(
    summaries: Dict[str, CLIPSummary],
    all_results: Dict[str, List[CLIPResult]],
    out_path: Path,
    clip_model_name: str
):
    """Generate markdown comparison table."""
    lines = []
    sources = sorted(summaries.keys())

    lines.append("# CLIP Score Evaluation Results")
    lines.append(f"\nGenerated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    lines.append(f"CLIP Model: {clip_model_name}\n")

    # Main comparison table
    lines.append("## Overall Comparison\n")
    lines.append("Higher CLIP Score = better text-image alignment.\n")
    header = "| Metric |"
    sep = "|--------|"
    for s in sources:
        header += f" {s} |"
        sep += "------|"
    lines.append(header)
    lines.append(sep)

    def fmt(val):
        return f"{val:.4f}" if np.isfinite(val) else "N/A"

    rows = [
        ("CLIP Score (mean) ↑", lambda s: s.clip_mean),
        ("CLIP Score (std)", lambda s: s.clip_std),
        ("CLIP Score (median)", lambda s: s.clip_median),
        ("CLIP Score (min)", lambda s: s.clip_min),
        ("CLIP Score (max)", lambda s: s.clip_max),
        ("Evaluated", lambda s: float(s.n_evaluated)),
        ("Skipped", lambda s: float(s.n_skipped)),
    ]

    for label, getter in rows:
        row = f"| {label} |"
        values = {}
        for s in sources:
            val = getter(summaries[s])
            values[s] = val
        # Bold the best score (highest for CLIP)
        if "↑" in label and len(sources) > 1:
            best = max((v for v in values.values() if np.isfinite(v)), default=None)
        else:
            best = None
        for s in sources:
            val = values[s]
            formatted = fmt(val)
            if best is not None and np.isfinite(val) and val == best:
                formatted = f"**{formatted}**"
            row += f" {formatted} |"
        lines.append(row)

    # Per-tier table
    lines.append("\n## Per-Tier Comparison\n")
    for tier in ["Simple", "Medium", "Complex"]:
        lines.append(f"\n### {tier}\n")
        header = "| Metric |"
        sep = "|--------|"
        for s in sources:
            header += f" {s} |"
            sep += "------|"
        lines.append(header)
        lines.append(sep)

        # Mean
        row = "| CLIP Score ↑ |"
        values = {}
        for s in sources:
            values[s] = summaries[s].clip_by_tier.get(tier, float('nan'))
        best = max((v for v in values.values() if np.isfinite(v)), default=None) if len(sources) > 1 else None
        for s in sources:
            val = values[s]
            formatted = fmt(val)
            if best is not None and np.isfinite(val) and val == best:
                formatted = f"**{formatted}**"
            row += f" {formatted} |"
        lines.append(row)

        # Count
        row = "| Count |"
        for s in sources:
            count = summaries[s].clip_count_by_tier.get(tier, 0)
            row += f" {count} |"
        lines.append(row)

    # Top/bottom samples (most interesting for analysis)
    if sources:
        first_source = sources[0]
        first_results = [r for r in all_results[first_source]
                         if not r.error and np.isfinite(r.clip_score)]
        if first_results:
            first_results_sorted = sorted(first_results, key=lambda r: r.clip_score, reverse=True)

            lines.append(f"\n## Top 10 Highest CLIP Scores ({first_source})\n")
            lines.append("| Rank | Prompt ID | Tier | CLIP Score | Prompt |")
            lines.append("|------|-----------|------|------------|--------|")
            for i, r in enumerate(first_results_sorted[:10], 1):
                prompt_short = r.prompt_text[:60] + "..." if len(r.prompt_text) > 60 else r.prompt_text
                lines.append(f"| {i} | {r.prompt_id} | {r.tier} | {fmt(r.clip_score)} | {prompt_short} |")

            lines.append(f"\n## Bottom 10 Lowest CLIP Scores ({first_source})\n")
            lines.append("| Rank | Prompt ID | Tier | CLIP Score | Prompt |")
            lines.append("|------|-----------|------|------------|--------|")
            for i, r in enumerate(first_results_sorted[-10:], 1):
                prompt_short = r.prompt_text[:60] + "..." if len(r.prompt_text) > 60 else r.prompt_text
                lines.append(f"| {i} | {r.prompt_id} | {r.tier} | {fmt(r.clip_score)} | {prompt_short} |")

    md_path = out_path / "clip_comparison_table.md"
    with open(md_path, 'w') as f:
        f.write("\n".join(lines))

    logger.info(f"CLIP comparison table saved to {md_path}")


def print_summary(summaries: Dict[str, CLIPSummary], clip_model_name: str):
    """Print a compact summary to console."""
    sources = sorted(summaries.keys())

    print(f"\n{'='*70}")
    print(f"CLIP SCORE EVALUATION SUMMARY  (model: {clip_model_name})")
    print(f"{'='*70}")

    header = f"{'Metric':<25}"
    for s in sources:
        header += f" {s:>12}"
    print(header)
    print("-" * len(header))

    def row(label, getter, fmt_str="{:>12.4f}"):
        line = f"{label:<25}"
        for s in sources:
            val = getter(summaries[s])
            if np.isnan(val):
                line += f" {'N/A':>12}"
            else:
                line += fmt_str.format(val)
        print(line)

    row("CLIP Score (mean) ↑", lambda s: s.clip_mean)
    row("CLIP Score (std)", lambda s: s.clip_std)
    row("CLIP Score (median)", lambda s: s.clip_median)
    row("CLIP Score (min)", lambda s: s.clip_min)
    row("CLIP Score (max)", lambda s: s.clip_max)
    row("Evaluated", lambda s: float(s.n_evaluated), "{:>12.0f}")
    row("Skipped", lambda s: float(s.n_skipped), "{:>12.0f}")

    for tier in ["Simple", "Medium", "Complex"]:
        print(f"\n  {tier}:")
        row(f"  CLIP ↑", lambda s, t=tier: s.clip_by_tier.get(t, float('nan')))
        row(f"  Count", lambda s, t=tier: float(s.clip_count_by_tier.get(t, 0)), "{:>12.0f}")

    print(f"\n{'='*70}")


# =============================================================================
# CLI
# =============================================================================

def main():
    parser = argparse.ArgumentParser(
        description="CLIP Score Evaluation — Text-Image Semantic Alignment",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # GT only (ceiling reference)
  python evaluate_clip_score.py --gt-png-dir ground_truth/png

  # Single model
  python evaluate_clip_score.py --gt-png-dir ground_truth/png \\
    --pred-png-dir results/craft/png --model-name craft

  # Multiple models
  python evaluate_clip_score.py --gt-png-dir ground_truth/png \\
    --models craft=results/craft/png gpt4o=results/gpt4o/png gpt52=results/gpt52/png

  # Different CLIP backbone
  python evaluate_clip_score.py --gt-png-dir ground_truth/png \\
    --clip-model ViT-B-32 --pretrained openai
        """
    )

    parser.add_argument("--gt-png-dir", type=str, required=True,
                        help="Directory containing ground truth rendered PNGs")
    parser.add_argument("--pred-png-dir", type=str, default=None,
                        help="Directory containing predicted PNGs (for single model)")
    parser.add_argument("--model-name", type=str, default="model",
                        help="Name of the model (for single model mode)")
    parser.add_argument("--models", nargs="+", default=None,
                        help="Multiple models as name=dir pairs "
                             "(e.g., craft=results/craft/png)")
    parser.add_argument("--benchmark-json", type=str,
                        default=str(SCRIPT_DIR / "benchmark_ground_truth.json"),
                        help="Path to benchmark_ground_truth.json")
    parser.add_argument("--prompt-ids", nargs="+", default=None,
                        help="Specific prompt IDs to evaluate")
    parser.add_argument("--output-dir", type=str,
                        default=str(SCRIPT_DIR / "evaluation_results" / "clip"),
                        help="Output directory for results")
    parser.add_argument("--clip-model", type=str, default="ViT-L-14",
                        help="CLIP model architecture (default: ViT-L-14)")
    parser.add_argument("--pretrained", type=str, default="openai",
                        help="Pretrained weights (default: openai)")
    parser.add_argument("--device", type=str, default="auto",
                        help="Device: auto | cuda | cpu")
    parser.add_argument("--batch-size", type=int, default=32,
                        help="Batch size for CLIP inference")

    args = parser.parse_args()

    # Load benchmark metadata
    components = load_benchmark_metadata(args.benchmark_json)

    # Load CLIP model
    clip_model_name = f"{args.clip_model}/{args.pretrained}"
    model, preprocess, tokenizer, device = load_clip_model(
        args.clip_model, args.pretrained, args.device
    )

    # Build source configurations: always include GT
    source_configs = {"gt": args.gt_png_dir}

    if args.models:
        for model_spec in args.models:
            name, png_dir = model_spec.split("=", 1)
            source_configs[name] = png_dir
    elif args.pred_png_dir:
        source_configs[args.model_name] = args.pred_png_dir

    # Run evaluation for each source
    all_results = {}
    all_summaries = {}

    for source_name, png_dir in source_configs.items():
        print(f"\n{'='*60}")
        print(f"Evaluating: {source_name} ({png_dir})")
        print(f"{'='*60}")

        results, summary = evaluate_source(
            components=components,
            png_dir=png_dir,
            source_name=source_name,
            model=model,
            preprocess=preprocess,
            tokenizer=tokenizer,
            device=device,
            prompt_ids=args.prompt_ids,
            batch_size=args.batch_size,
        )
        summary.clip_model = clip_model_name

        all_results[source_name] = results
        all_summaries[source_name] = summary

    # Print summary to console
    print_summary(all_summaries, clip_model_name)

    # Save results
    save_results(all_results, all_summaries, args.output_dir, clip_model_name)


if __name__ == "__main__":
    main()
