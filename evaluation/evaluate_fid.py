#!/usr/bin/env python3
"""
FID (Fréchet Inception Distance) Evaluation for Text2CAD SPM 2026

Measures the distributional similarity between GT renders and model renders.
Unlike per-sample metrics (CD, F1, LPIPS), FID gives ONE number for the
entire dataset, capturing both quality and diversity of generated outputs.

Lower FID = the distribution of generated renders is closer to the
distribution of real (GT) renders.

Usage:
    # Single model
    python evaluate_fid.py \
        --gt-png-dir ground_truth/png \
        --pred-png-dir results/cadence/png \
        --model-name cadence

    # Multiple models at once
    python evaluate_fid.py \
        --gt-png-dir ground_truth/png \
        --models cadence=results/cadence/png \
                 gpt4o=results/gpt4o/png \
                 gpt52=results/gpt52/png

Requirements:
    pip install torch torchvision pillow numpy scipy

How FID works:
    1. Pass ALL GT images through Inception-v3 → 2048-dim feature per image
    2. Pass ALL Pred images through Inception-v3 → 2048-dim feature per image
    3. Fit a multivariate Gaussian to each set:
         GT:   (μ_gt, Σ_gt)       μ = mean vector, Σ = covariance matrix
         Pred: (μ_pred, Σ_pred)
    4. Compute the Fréchet distance between the two Gaussians:
         FID = ||μ_gt - μ_pred||² + Tr(Σ_gt + Σ_pred - 2·(Σ_gt·Σ_pred)^½)
               |___ mean shift ___|   |_______ covariance difference _______|

    The first term measures if predictions are systematically shifted
    in feature space (e.g., always too smooth or too noisy).
    The second term measures if the spread/diversity differs (e.g.,
    predictions are all similar while GT has high variety).

    Score range: 0 (identical distributions) to 100+ (very different)
    Lower is better.

Important notes:
    - FID is a DISTRIBUTIONAL metric: one number for the whole dataset
    - Needs 50+ images minimum to be statistically meaningful
    - This script uses Inception-v3 pool3 features (2048-dim), the standard
      for FID as established by Heusel et al. (2017)
    - Per-tier FID is included but should be interpreted cautiously with
      small tier sizes (~150 per tier)
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

# Minimum samples needed for FID to be meaningful
MIN_SAMPLES_OVERALL = 50
MIN_SAMPLES_TIER = 30


# =============================================================================
# DATA STRUCTURES
# =============================================================================

@dataclass
class FIDResult:
    """FID score for a GT↔Model comparison (one number per model)."""
    model_name: str
    fid_score: float = float('nan')        # Overall FID (lower is better)
    n_gt_images: int = 0
    n_pred_images: int = 0
    n_matched: int = 0                     # Images present in both GT and Pred
    fid_by_tier: Dict[str, float] = field(default_factory=dict)
    count_by_tier: Dict[str, int] = field(default_factory=dict)
    error: str = ""
    compute_time_s: float = 0.0


# =============================================================================
# INCEPTION-V3 FEATURE EXTRACTOR
# =============================================================================

class InceptionFeatureExtractor:
    """
    Extract 2048-dim features from Inception-v3's pool3 layer.

    This is the standard feature extractor for FID. We use the pretrained
    Inception-v3 from torchvision with ImageNet weights, and hook into
    the average pooling layer right before the final classifier.

    The extracted features capture a rich hierarchy of visual information:
      - Early layers: edges, colors, simple textures
      - Middle layers: shapes, parts, texture combinations
      - Final pooling (what we extract): holistic object representation

    Each image becomes a single 2048-dimensional vector.
    """

    def __init__(self, device: str = "auto"):
        try:
            import torch
            import torchvision.models as models
            import torchvision.transforms as transforms
        except ImportError:
            logger.error(
                "Required packages not found. Install with:\n"
                "  pip install torch torchvision pillow numpy scipy"
            )
            sys.exit(1)

        if device == "auto":
            device = "cuda" if torch.cuda.is_available() else "cpu"
        self.device = device
        self.torch = torch

        logger.info(f"Loading Inception-v3 on {device}")

        # Load pretrained Inception-v3
        self.model = models.inception_v3(weights=models.Inception_V3_Weights.DEFAULT)
        self.model.eval()
        self.model.to(device)

        # Hook to capture features from the avgpool layer (2048-dim)
        # Inception-v3 architecture: ... → Mixed_7c → avgpool → dropout → fc
        # We want the output of avgpool, which is a 2048-dim vector
        self._features = None

        def hook_fn(module, input, output):
            # output shape: [batch, 2048, 1, 1] → squeeze to [batch, 2048]
            self._features = output.squeeze(-1).squeeze(-1)

        self.model.avgpool.register_forward_hook(hook_fn)

        # Standard Inception-v3 preprocessing:
        #   - Resize to 299×299 (Inception's native resolution)
        #   - Normalize to ImageNet stats
        self.transform = transforms.Compose([
            transforms.Resize((299, 299)),
            transforms.ToTensor(),
            transforms.Normalize(
                mean=[0.485, 0.456, 0.406],
                std=[0.229, 0.224, 0.225]
            ),
        ])

        logger.info("Inception-v3 loaded successfully")

    def extract_features(self, image_paths: List[str],
                         batch_size: int = 32) -> np.ndarray:
        """
        Extract 2048-dim features for a list of images.

        Args:
            image_paths: List of PNG file paths
            batch_size: Images per batch

        Returns:
            numpy array of shape (N, 2048)
        """
        from PIL import Image

        all_features = []

        for batch_start in range(0, len(image_paths), batch_size):
            batch_end = min(batch_start + batch_size, len(image_paths))
            batch_paths = image_paths[batch_start:batch_end]

            tensors = []
            for path in batch_paths:
                try:
                    img = Image.open(path).convert("RGB")
                    tensors.append(self.transform(img))
                except Exception as e:
                    logger.warning(f"Failed to load {path}: {e}")
                    continue

            if not tensors:
                continue

            batch_tensor = self.torch.stack(tensors).to(self.device)

            with self.torch.no_grad():
                # Forward pass — we don't care about the classification output,
                # we only want the features captured by the hook
                _ = self.model(batch_tensor)
                features = self._features.cpu().numpy()
                all_features.append(features)

        if not all_features:
            return np.array([]).reshape(0, 2048)

        return np.concatenate(all_features, axis=0)


# =============================================================================
# FID COMPUTATION
# =============================================================================

def compute_fid(features_gt: np.ndarray, features_pred: np.ndarray) -> float:
    """
    Compute the Fréchet Inception Distance between two sets of features.

    FID = ||μ_gt - μ_pred||² + Tr(Σ_gt + Σ_pred - 2·(Σ_gt · Σ_pred)^½)

    Where:
      μ_gt, μ_pred     = mean feature vectors (2048-dim)
      Σ_gt, Σ_pred     = covariance matrices (2048 × 2048)
      Tr()             = matrix trace (sum of diagonal)
      (...)^½          = matrix square root

    The matrix square root is the expensive part. We compute it via
    eigendecomposition of the product Σ_gt · Σ_pred, which is numerically
    more stable than direct sqrtm.

    Args:
        features_gt: (N, 2048) GT feature array
        features_pred: (M, 2048) Pred feature array

    Returns:
        FID score (float, lower is better)
    """
    from scipy import linalg

    # Step 1: Compute means
    mu_gt = np.mean(features_gt, axis=0)
    mu_pred = np.mean(features_pred, axis=0)

    # Step 2: Compute covariance matrices
    # rowvar=False because each row is an observation, each column is a feature
    sigma_gt = np.cov(features_gt, rowvar=False)
    sigma_pred = np.cov(features_pred, rowvar=False)

    # Step 3: Mean difference term
    diff = mu_gt - mu_pred
    mean_term = np.dot(diff, diff)

    # Step 4: Covariance term — need matrix square root of (Σ_gt · Σ_pred)
    # Using scipy's sqrtm which handles the matrix square root
    product = sigma_gt @ sigma_pred

    # sqrtm can return complex numbers due to numerical errors
    # We take the real part (imaginary parts should be negligible)
    sqrt_product, _ = linalg.sqrtm(product, disp=False)

    # Handle numerical errors: if result has small imaginary parts, take real
    if np.iscomplexobj(sqrt_product):
        if np.max(np.abs(sqrt_product.imag)) > 1e-3:
            logger.warning(
                f"Large imaginary component in sqrtm: {np.max(np.abs(sqrt_product.imag)):.6f}. "
                f"FID may be unreliable."
            )
        sqrt_product = sqrt_product.real

    cov_term = np.trace(sigma_gt + sigma_pred - 2.0 * sqrt_product)

    fid = float(mean_term + cov_term)

    # FID should be non-negative; small negative values are numerical artifacts
    return max(fid, 0.0)


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


def evaluate_model(
    components: List[dict],
    gt_png_dir: str,
    pred_png_dir: str,
    model_name: str,
    extractor: InceptionFeatureExtractor,
    gt_features_cache: Optional[Dict] = None,
    prompt_ids: Optional[List[str]] = None,
    batch_size: int = 32
) -> Tuple[FIDResult, Optional[Dict]]:
    """
    Evaluate FID for one model against GT.

    Args:
        components: List of component metadata dicts
        gt_png_dir: Directory containing GT rendered PNGs
        pred_png_dir: Directory containing predicted PNGs
        model_name: Name of the model
        extractor: Inception-v3 feature extractor
        gt_features_cache: Cached GT features from previous model evaluation
                          (avoids re-extracting GT features for each model)
        prompt_ids: Optional subset of IDs to evaluate
        batch_size: Batch size for feature extraction

    Returns:
        (FIDResult, gt_features_cache for reuse)
    """
    logger.info(f"Evaluating FID for: {model_name}")
    logger.info(f"  GT:   {gt_png_dir}")
    logger.info(f"  Pred: {pred_png_dir}")

    if prompt_ids:
        id_set = set(prompt_ids)
        components = [c for c in components if c["id"] in id_set]

    result = FIDResult(model_name=model_name)
    t0 = time.time()

    # Find matched pairs (both GT and Pred PNGs exist)
    matched = []
    for comp in components:
        comp_id = comp["id"]
        gt_path = os.path.join(gt_png_dir, f"{comp_id}.png")
        pred_path = os.path.join(pred_png_dir, f"{comp_id}.png")

        if os.path.exists(gt_path) and os.path.exists(pred_path):
            matched.append({
                "id": comp_id,
                "gt_path": gt_path,
                "pred_path": pred_path,
                "tier": comp.get("tier", ""),
            })

    n_gt = sum(1 for c in components
               if os.path.exists(os.path.join(gt_png_dir, f"{c['id']}.png")))
    n_pred = sum(1 for c in components
                 if os.path.exists(os.path.join(pred_png_dir, f"{c['id']}.png")))

    result.n_gt_images = n_gt
    result.n_pred_images = n_pred
    result.n_matched = len(matched)

    logger.info(f"  GT images: {n_gt}, Pred images: {n_pred}, Matched: {len(matched)}")

    if len(matched) < MIN_SAMPLES_OVERALL:
        result.error = (
            f"Only {len(matched)} matched pairs (need {MIN_SAMPLES_OVERALL}+). "
            f"FID is not meaningful with so few samples."
        )
        logger.warning(f"  {result.error}")
        return result, gt_features_cache

    # Extract features (or use cache for GT)
    gt_paths = [m["gt_path"] for m in matched]
    pred_paths = [m["pred_path"] for m in matched]

    # Cache key: frozenset of GT paths (to detect if GT set changed)
    cache_key = frozenset(gt_paths)

    if gt_features_cache and gt_features_cache.get("key") == cache_key:
        logger.info(f"  Using cached GT features ({len(gt_paths)} images)")
        gt_features = gt_features_cache["features"]
        gt_tiers = gt_features_cache["tiers"]
    else:
        logger.info(f"  Extracting GT features ({len(gt_paths)} images)...")
        gt_features = extractor.extract_features(gt_paths, batch_size=batch_size)
        gt_tiers = [m["tier"] for m in matched]
        gt_features_cache = {
            "key": cache_key,
            "features": gt_features,
            "tiers": gt_tiers,
        }

    logger.info(f"  Extracting Pred features ({len(pred_paths)} images)...")
    pred_features = extractor.extract_features(pred_paths, batch_size=batch_size)

    if len(gt_features) == 0 or len(pred_features) == 0:
        result.error = "Feature extraction failed (no valid images)"
        return result, gt_features_cache

    # Compute overall FID
    logger.info(f"  Computing FID ({len(gt_features)} GT vs {len(pred_features)} Pred)...")
    result.fid_score = compute_fid(gt_features, pred_features)
    logger.info(f"  Overall FID: {result.fid_score:.2f}")

    # Compute per-tier FID
    tiers_list = [m["tier"] for m in matched]
    for tier in ["Simple", "Medium", "Complex"]:
        tier_indices = [i for i, t in enumerate(tiers_list) if t == tier]

        if len(tier_indices) < MIN_SAMPLES_TIER:
            logger.info(
                f"  {tier}: only {len(tier_indices)} samples "
                f"(need {MIN_SAMPLES_TIER}+), skipping per-tier FID"
            )
            continue

        tier_gt = gt_features[tier_indices]
        tier_pred = pred_features[tier_indices]
        tier_fid = compute_fid(tier_gt, tier_pred)
        result.fid_by_tier[tier] = tier_fid
        result.count_by_tier[tier] = len(tier_indices)
        logger.info(f"  {tier} FID: {tier_fid:.2f} (n={len(tier_indices)})")

    result.compute_time_s = time.time() - t0
    return result, gt_features_cache


# =============================================================================
# OUTPUT FORMATTERS
# =============================================================================

def save_results(
    all_results: Dict[str, FIDResult],
    output_dir: str
):
    """Save FID results to JSON and markdown."""
    out_path = Path(output_dir)
    out_path.mkdir(parents=True, exist_ok=True)

    # Save results as JSON
    results_data = {name: asdict(r) for name, r in all_results.items()}
    with open(out_path / "fid_results.json", 'w') as f:
        json.dump(results_data, f, indent=2, default=str)

    # Generate markdown table
    _generate_markdown_table(all_results, out_path)

    logger.info(f"Results saved to {out_path}")


def _generate_markdown_table(
    all_results: Dict[str, FIDResult],
    out_path: Path
):
    """Generate markdown comparison table."""
    lines = []
    models = sorted(all_results.keys())

    lines.append("# FID (Fréchet Inception Distance) Evaluation Results")
    lines.append(f"\nGenerated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    lines.append(f"Feature extractor: Inception-v3 (pool3, 2048-dim)")
    lines.append(f"Lower FID = generated renders are distributionally closer to GT renders.\n")

    def fmt(val):
        return f"{val:.2f}" if np.isfinite(val) else "N/A"

    # Main comparison table
    lines.append("## Overall Comparison\n")
    header = "| Metric |"
    sep = "|--------|"
    for m in models:
        header += f" {m} |"
        sep += "------|"
    lines.append(header)
    lines.append(sep)

    # FID row with best bolded
    row = "| FID ↓ |"
    values = {m: all_results[m].fid_score for m in models}
    finite_vals = [v for v in values.values() if np.isfinite(v)]
    best = min(finite_vals) if finite_vals and len(models) > 1 else None
    for m in models:
        val = values[m]
        formatted = fmt(val)
        if best is not None and np.isfinite(val) and val == best:
            formatted = f"**{formatted}**"
        row += f" {formatted} |"
    lines.append(row)

    # Sample counts
    row = "| Matched pairs |"
    for m in models:
        row += f" {all_results[m].n_matched} |"
    lines.append(row)

    row = "| GT images |"
    for m in models:
        row += f" {all_results[m].n_gt_images} |"
    lines.append(row)

    row = "| Pred images |"
    for m in models:
        row += f" {all_results[m].n_pred_images} |"
    lines.append(row)

    # Per-tier table
    lines.append("\n## Per-Tier FID\n")
    lines.append(f"Note: Per-tier FID is computed with ~150 samples per tier. "
                 f"Interpret with caution — FID is most reliable with 500+ samples.\n")

    header = "| Tier |"
    sep = "|------|"
    for m in models:
        header += f" {m} |"
        sep += "------|"
    lines.append(header)
    lines.append(sep)

    for tier in ["Simple", "Medium", "Complex"]:
        row = f"| {tier} |"
        values = {}
        for m in models:
            values[m] = all_results[m].fid_by_tier.get(tier, float('nan'))
        finite_vals = [v for v in values.values() if np.isfinite(v)]
        best = min(finite_vals) if finite_vals and len(models) > 1 else None
        for m in models:
            val = values[m]
            count = all_results[m].count_by_tier.get(tier, 0)
            formatted = fmt(val)
            if best is not None and np.isfinite(val) and val == best:
                formatted = f"**{formatted}**"
            if count > 0:
                formatted += f" (n={count})"
            row += f" {formatted} |"
        lines.append(row)

    # Errors
    errors = {m: all_results[m].error for m in models if all_results[m].error}
    if errors:
        lines.append("\n## Warnings\n")
        for m, err in errors.items():
            lines.append(f"- **{m}**: {err}")

    # Interpretation guide
    lines.append("\n## Interpretation Guide\n")
    lines.append("| FID Range | Interpretation |")
    lines.append("|-----------|----------------|")
    lines.append("| 0–10 | Very similar distributions (excellent) |")
    lines.append("| 10–50 | Good quality, some distributional differences |")
    lines.append("| 50–100 | Noticeable differences in quality or diversity |")
    lines.append("| 100+ | Very different distributions |")
    lines.append("")
    lines.append("Note: These ranges are approximate. FID values depend heavily on "
                 "the domain (CAD renders vs natural photos) and dataset size. "
                 "Compare models against each other, not against absolute thresholds.")

    md_path = out_path / "fid_comparison_table.md"
    with open(md_path, 'w') as f:
        f.write("\n".join(lines))

    logger.info(f"FID comparison table saved to {md_path}")


def print_summary(all_results: Dict[str, FIDResult]):
    """Print a compact summary to console."""
    models = sorted(all_results.keys())

    print(f"\n{'='*70}")
    print(f"FID EVALUATION SUMMARY  (Inception-v3 pool3 features)")
    print(f"{'='*70}")

    header = f"{'Metric':<25}"
    for m in models:
        header += f" {m:>12}"
    print(header)
    print("-" * len(header))

    def fmt(val):
        return f"{val:>12.2f}" if np.isfinite(val) else f"{'N/A':>12}"

    line = f"{'FID ↓':<25}"
    for m in models:
        line += fmt(all_results[m].fid_score)
    print(line)

    line = f"{'Matched pairs':<25}"
    for m in models:
        line += f"{all_results[m].n_matched:>12d}"
    print(line)

    for tier in ["Simple", "Medium", "Complex"]:
        line = f"{f'  {tier}':<25}"
        for m in models:
            val = all_results[m].fid_by_tier.get(tier, float('nan'))
            count = all_results[m].count_by_tier.get(tier, 0)
            if np.isfinite(val):
                line += f"{val:>9.2f}({count:d})"
            else:
                line += f"{'N/A':>12}"
        print(line)

    for m in models:
        if all_results[m].error:
            print(f"\n  WARNING ({m}): {all_results[m].error}")

    print(f"\n{'='*70}")


# =============================================================================
# CLI
# =============================================================================

def main():
    parser = argparse.ArgumentParser(
        description="FID Evaluation — Fréchet Inception Distance",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Single model
  python evaluate_fid.py --gt-png-dir ground_truth/png \\
    --pred-png-dir results/cadence/png --model-name cadence

  # Multiple models (GT features are extracted once and reused)
  python evaluate_fid.py --gt-png-dir ground_truth/png \\
    --models cadence=results/cadence/png gpt4o=results/gpt4o/png gpt52=results/gpt52/png
        """
    )

    parser.add_argument("--gt-png-dir", type=str, required=True,
                        help="Directory containing ground truth rendered PNGs")
    parser.add_argument("--pred-png-dir", type=str, default=None,
                        help="Directory containing predicted PNGs (single model)")
    parser.add_argument("--model-name", type=str, default="model",
                        help="Name of the model (for single model mode)")
    parser.add_argument("--models", nargs="+", default=None,
                        help="Multiple models as name=dir pairs "
                             "(e.g., cadence=results/cadence/png)")
    parser.add_argument("--benchmark-json", type=str,
                        default=str(SCRIPT_DIR / "benchmark_ground_truth.json"),
                        help="Path to benchmark_ground_truth.json")
    parser.add_argument("--prompt-ids", nargs="+", default=None,
                        help="Specific prompt IDs to evaluate")
    parser.add_argument("--output-dir", type=str,
                        default=str(SCRIPT_DIR / "evaluation_results" / "fid"),
                        help="Output directory for results")
    parser.add_argument("--device", type=str, default="auto",
                        help="Device: auto | cuda | cpu")
    parser.add_argument("--batch-size", type=int, default=32,
                        help="Batch size for Inception-v3 inference")

    args = parser.parse_args()

    # Validate
    if not args.pred_png_dir and not args.models:
        parser.error(
            "FID requires predicted PNGs to compare against GT.\n"
            "Use --pred-png-dir or --models to specify model outputs."
        )

    # Load benchmark metadata
    components = load_benchmark_metadata(args.benchmark_json)

    # Load Inception-v3
    extractor = InceptionFeatureExtractor(device=args.device)

    # Build model configurations
    model_configs = {}
    if args.models:
        for model_spec in args.models:
            name, png_dir = model_spec.split("=", 1)
            model_configs[name] = png_dir
    else:
        model_configs[args.model_name] = args.pred_png_dir

    # Run evaluation — GT features are cached across models
    all_results = {}
    gt_cache = None

    for model_name, pred_dir in model_configs.items():
        print(f"\n{'='*60}")
        print(f"Evaluating: {model_name}")
        print(f"{'='*60}")

        result, gt_cache = evaluate_model(
            components=components,
            gt_png_dir=args.gt_png_dir,
            pred_png_dir=pred_dir,
            model_name=model_name,
            extractor=extractor,
            gt_features_cache=gt_cache,
            prompt_ids=args.prompt_ids,
            batch_size=args.batch_size,
        )

        all_results[model_name] = result

    # Print summary
    print_summary(all_results)

    # Save results
    save_results(all_results, args.output_dir)


if __name__ == "__main__":
    main()
