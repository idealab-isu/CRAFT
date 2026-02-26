"""
Visual Verifier

Compares generated CAD renders against knowledge base reference images.
Uses multiple metrics (SSIM, IoU, perceptual) and VLM analysis.
"""

import os
import base64
from pathlib import Path
from dataclasses import dataclass, field
from typing import List, Dict, Optional, Tuple, Any

import numpy as np
from PIL import Image

try:
    from scipy.ndimage import binary_dilation
    SCIPY_AVAILABLE = True
except ImportError:
    SCIPY_AVAILABLE = False

from .config import KB_CONFIG, VerificationThresholds
from .retriever import RetrievalResult


@dataclass
class ViewComparison:
    """Comparison result for a single view."""
    view_name: str
    ssim_score: float
    iou_score: float
    mse_score: float
    passed: bool
    generated_path: Optional[Path] = None
    reference_path: Optional[Path] = None


@dataclass
class VerificationResult:
    """Result of visual verification against KB reference."""
    component_id: str
    component_name: str
    overall_passed: bool
    overall_score: float              # Combined score 0-1
    view_comparisons: List[ViewComparison] = field(default_factory=list)
    best_view: Optional[str] = None
    worst_view: Optional[str] = None
    vlm_analysis: Optional[str] = None  # VLM description of differences
    repair_suggestions: List[str] = field(default_factory=list)

    def get_failing_views(self) -> List[ViewComparison]:
        """Get views that failed verification."""
        return [v for v in self.view_comparisons if not v.passed]

    def get_summary(self) -> str:
        """Get a summary of the verification result."""
        status = "PASSED" if self.overall_passed else "FAILED"
        passed_count = sum(1 for v in self.view_comparisons if v.passed)
        total = len(self.view_comparisons)

        summary = f"Verification {status}: {self.component_name}\n"
        summary += f"Overall score: {self.overall_score:.2%}\n"
        summary += f"Views passed: {passed_count}/{total}\n"

        if self.view_comparisons:
            summary += "\nView details:\n"
            for vc in self.view_comparisons:
                status_icon = "✓" if vc.passed else "✗"
                summary += f"  {status_icon} {vc.view_name}: SSIM={vc.ssim_score:.3f}, IoU={vc.iou_score:.3f}\n"

        if self.repair_suggestions:
            summary += "\nSuggested repairs:\n"
            for suggestion in self.repair_suggestions:
                summary += f"  - {suggestion}\n"

        return summary


class VisualVerifier:
    """
    Verifies generated CAD output against knowledge base references.

    Uses multiple comparison strategies:
    1. SSIM (Structural Similarity Index)
    2. Silhouette IoU (Intersection over Union)
    3. MSE (Mean Squared Error)
    4. VLM-based semantic comparison (optional)
    """

    def __init__(
        self,
        thresholds: VerificationThresholds = None,
        use_vlm: bool = True
    ):
        self.thresholds = thresholds or KB_CONFIG.verification
        self.use_vlm = use_vlm

        # VLM client (reuse from existing pipeline)
        self.llm_client = None

    def _load_image(self, path: Path) -> Optional[np.ndarray]:
        """Load an image as numpy array."""
        try:
            img = Image.open(path).convert('L')  # Grayscale
            return np.array(img)
        except Exception as e:
            print(f"Error loading image {path}: {e}")
            return None

    def _load_image_rgb(self, path: Path) -> Optional[np.ndarray]:
        """Load an image as RGB numpy array."""
        try:
            img = Image.open(path).convert('RGB')
            return np.array(img)
        except Exception as e:
            print(f"Error loading image {path}: {e}")
            return None

    def compute_ssim(
        self,
        img1: np.ndarray,
        img2: np.ndarray,
        window_size: int = 11
    ) -> float:
        """
        Compute Structural Similarity Index (SSIM) between two images.

        Returns value between 0 (different) and 1 (identical).
        """
        # Resize if different sizes
        if img1.shape != img2.shape:
            h = min(img1.shape[0], img2.shape[0])
            w = min(img1.shape[1], img2.shape[1])
            img1 = np.array(Image.fromarray(img1).resize((w, h)))
            img2 = np.array(Image.fromarray(img2).resize((w, h)))

        # Constants for stability
        C1 = (0.01 * 255) ** 2
        C2 = (0.03 * 255) ** 2

        img1 = img1.astype(np.float64)
        img2 = img2.astype(np.float64)

        # Compute means
        mu1 = img1.mean()
        mu2 = img2.mean()

        # Compute variances and covariance
        sigma1_sq = ((img1 - mu1) ** 2).mean()
        sigma2_sq = ((img2 - mu2) ** 2).mean()
        sigma12 = ((img1 - mu1) * (img2 - mu2)).mean()

        # SSIM formula
        ssim = ((2 * mu1 * mu2 + C1) * (2 * sigma12 + C2)) / \
               ((mu1 ** 2 + mu2 ** 2 + C1) * (sigma1_sq + sigma2_sq + C2))

        return float(ssim)

    def compute_silhouette_iou(
        self,
        img1: np.ndarray,
        img2: np.ndarray,
        threshold: int = 250
    ) -> float:
        """
        Compute Intersection over Union of silhouettes.

        Args:
            img1, img2: Grayscale images
            threshold: Value to threshold for foreground

        Returns:
            IoU score between 0 and 1
        """
        # Resize if different sizes
        if img1.shape != img2.shape:
            h = min(img1.shape[0], img2.shape[0])
            w = min(img1.shape[1], img2.shape[1])
            img1 = np.array(Image.fromarray(img1).resize((w, h)))
            img2 = np.array(Image.fromarray(img2).resize((w, h)))

        # Create binary masks (foreground = non-white)
        mask1 = img1 < threshold
        mask2 = img2 < threshold

        # Compute IoU
        intersection = np.logical_and(mask1, mask2).sum()
        union = np.logical_or(mask1, mask2).sum()

        if union == 0:
            return 1.0 if intersection == 0 else 0.0

        return float(intersection / union)

    def compute_mse(self, img1: np.ndarray, img2: np.ndarray) -> float:
        """Compute Mean Squared Error between images."""
        # Resize if different sizes
        if img1.shape != img2.shape:
            h = min(img1.shape[0], img2.shape[0])
            w = min(img1.shape[1], img2.shape[1])
            img1 = np.array(Image.fromarray(img1).resize((w, h)))
            img2 = np.array(Image.fromarray(img2).resize((w, h)))

        return float(np.mean((img1.astype(float) - img2.astype(float)) ** 2))

    def compare_images(
        self,
        generated_path: Path,
        reference_path: Path,
        view_name: str = "unknown"
    ) -> ViewComparison:
        """
        Compare a generated image against a reference.

        Args:
            generated_path: Path to generated render
            reference_path: Path to reference image
            view_name: Name of the view being compared

        Returns:
            ViewComparison with all metrics
        """
        # Load images
        gen_img = self._load_image(generated_path)
        ref_img = self._load_image(reference_path)

        if gen_img is None or ref_img is None:
            return ViewComparison(
                view_name=view_name,
                ssim_score=0.0,
                iou_score=0.0,
                mse_score=float('inf'),
                passed=False,
                generated_path=generated_path,
                reference_path=reference_path
            )

        # Compute metrics
        ssim = self.compute_ssim(gen_img, ref_img)
        iou = self.compute_silhouette_iou(gen_img, ref_img)
        mse = self.compute_mse(gen_img, ref_img)

        # Determine if passed
        ssim_passed = ssim >= self.thresholds.ssim_min
        iou_passed = iou >= self.thresholds.iou_min

        if self.thresholds.require_both:
            passed = ssim_passed and iou_passed
        else:
            passed = ssim_passed or iou_passed

        return ViewComparison(
            view_name=view_name,
            ssim_score=ssim,
            iou_score=iou,
            mse_score=mse,
            passed=passed,
            generated_path=generated_path,
            reference_path=reference_path
        )

    def verify_component(
        self,
        component_id: str,
        component_name: str,
        generated_images: Dict[str, Path],
        reference_images: Dict[str, Path]
    ) -> VerificationResult:
        """
        Verify generated component against KB reference.

        Args:
            component_id: Component identifier
            component_name: Human-readable name
            generated_images: Dict of view_name → generated image path
            reference_images: Dict of view_name → reference image path

        Returns:
            VerificationResult with detailed comparison
        """
        view_comparisons = []
        scores = []

        # Compare each view that has both generated and reference
        for view_name in generated_images.keys():
            gen_path = generated_images.get(view_name)
            ref_path = reference_images.get(view_name)

            if gen_path is None or ref_path is None:
                continue

            if not gen_path.exists() or not ref_path.exists():
                continue

            comparison = self.compare_images(gen_path, ref_path, view_name)
            view_comparisons.append(comparison)

            # Combined score for this view
            view_score = (comparison.ssim_score + comparison.iou_score) / 2
            scores.append(view_score)

        # Calculate overall score
        if scores:
            overall_score = sum(scores) / len(scores)
        else:
            overall_score = 0.0

        # Determine overall pass/fail
        if view_comparisons:
            passed_count = sum(1 for vc in view_comparisons if vc.passed)
            # Require majority of views to pass
            overall_passed = passed_count >= len(view_comparisons) / 2
        else:
            overall_passed = False

        # Find best and worst views
        if view_comparisons:
            sorted_views = sorted(
                view_comparisons,
                key=lambda v: (v.ssim_score + v.iou_score) / 2,
                reverse=True
            )
            best_view = sorted_views[0].view_name
            worst_view = sorted_views[-1].view_name
        else:
            best_view = None
            worst_view = None

        # Generate repair suggestions based on failures
        repair_suggestions = self._generate_repair_suggestions(view_comparisons)

        return VerificationResult(
            component_id=component_id,
            component_name=component_name,
            overall_passed=overall_passed,
            overall_score=overall_score,
            view_comparisons=view_comparisons,
            best_view=best_view,
            worst_view=worst_view,
            repair_suggestions=repair_suggestions
        )

    def _generate_repair_suggestions(
        self,
        view_comparisons: List[ViewComparison]
    ) -> List[str]:
        """Generate repair suggestions based on failed comparisons."""
        suggestions = []

        for vc in view_comparisons:
            if vc.passed:
                continue

            if vc.ssim_score < 0.5:
                suggestions.append(
                    f"Major structural differences in {vc.view_name} view - "
                    "check overall shape and proportions"
                )
            elif vc.ssim_score < self.thresholds.ssim_min:
                suggestions.append(
                    f"Minor structural differences in {vc.view_name} view - "
                    "check details and fine features"
                )

            if vc.iou_score < 0.5:
                suggestions.append(
                    f"Silhouette mismatch in {vc.view_name} view - "
                    "check bounding dimensions and position"
                )
            elif vc.iou_score < self.thresholds.iou_min:
                suggestions.append(
                    f"Slight silhouette deviation in {vc.view_name} view - "
                    "check edge details and cutouts"
                )

        # Deduplicate
        return list(dict.fromkeys(suggestions))

    async def verify_with_vlm(
        self,
        generated_path: Path,
        reference_path: Path,
        component_name: str
    ) -> str:
        """
        Use VLM to analyze differences between generated and reference.

        Returns detailed description of differences and repair hints.
        """
        if not self.use_vlm or self.llm_client is None:
            return ""

        # Encode images
        def encode_image(path: Path) -> str:
            with open(path, "rb") as f:
                return base64.b64encode(f.read()).decode('utf-8')

        try:
            gen_b64 = encode_image(generated_path)
            ref_b64 = encode_image(reference_path)
        except Exception as e:
            return f"Error encoding images: {e}"

        prompt = f"""Compare these two images of a CAD component ({component_name}).

Image 1 (Left): Generated output
Image 2 (Right): Reference from knowledge base

Analyze the differences and provide:
1. What specific features differ between the images?
2. What parameters might be wrong (dimensions, positions, angles)?
3. What changes to the OpenSCAD code would make the generated match the reference?

Be specific and actionable in your suggestions."""

        try:
            # This would use the LLM client - implementation depends on your setup
            # For now, return empty (actual implementation would call VLM)
            return ""
        except Exception as e:
            return f"VLM analysis error: {e}"

    def verify_retrieval_result(
        self,
        retrieval_result: RetrievalResult,
        generated_images: Dict[str, Path]
    ) -> VerificationResult:
        """
        Verify generated output against a retrieval result.

        Args:
            retrieval_result: Result from KB retrieval
            generated_images: Generated images to verify

        Returns:
            VerificationResult
        """
        return self.verify_component(
            component_id=retrieval_result.component.id,
            component_name=retrieval_result.component.name,
            generated_images=generated_images,
            reference_images=retrieval_result.reference_images
        )


# Convenience functions

def verify_against_reference(
    component_id: str,
    component_name: str,
    generated_images: Dict[str, Path],
    reference_images: Dict[str, Path]
) -> VerificationResult:
    """
    Verify generated images against KB references.

    Args:
        component_id: Component identifier
        component_name: Display name
        generated_images: Dict of view → path for generated
        reference_images: Dict of view → path for reference

    Returns:
        VerificationResult
    """
    verifier = VisualVerifier()
    return verifier.verify_component(
        component_id,
        component_name,
        generated_images,
        reference_images
    )


def quick_verify(
    generated_path: Path,
    reference_path: Path
) -> Tuple[bool, float, float]:
    """
    Quick verification of two images.

    Returns:
        (passed, ssim_score, iou_score)
    """
    verifier = VisualVerifier()
    comparison = verifier.compare_images(
        generated_path,
        reference_path,
        view_name="quick"
    )
    return comparison.passed, comparison.ssim_score, comparison.iou_score
