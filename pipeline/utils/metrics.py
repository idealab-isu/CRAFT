"""
CRAFT Metrics Module

Provides image comparison metrics for evaluation:
- SSIM (Structural Similarity Index)
- Silhouette IoU (Intersection over Union)
- MSE / PSNR (for completeness)

3D geometry metrics:
- F-score (precision/recall at distance threshold)
- Voxel IoU (volumetric intersection over union)
"""

import numpy as np
from PIL import Image
from typing import Tuple, Optional, Union


# =============================================================================
# IMAGE LOADING UTILITIES
# =============================================================================

def load_image_grayscale(path: str) -> np.ndarray:
    """
    Load an image as grayscale numpy array.
    
    Args:
        path: Path to image file
        
    Returns:
        2D numpy array (float, 0-1 range)
    """
    img = Image.open(path).convert('L')
    return np.array(img, dtype=np.float64) / 255.0


def load_image_rgb(path: str) -> np.ndarray:
    """
    Load an image as RGB numpy array.
    
    Args:
        path: Path to image file
        
    Returns:
        3D numpy array (float, 0-1 range)
    """
    img = Image.open(path).convert('RGB')
    return np.array(img, dtype=np.float64) / 255.0


def to_silhouette(img: np.ndarray, threshold: float = 0.5) -> np.ndarray:
    """
    Convert image to binary silhouette.
    
    Args:
        img: Grayscale image array (0-1)
        threshold: Binarization threshold
        
    Returns:
        Binary array (0 or 1)
    """
    if len(img.shape) == 3:
        img = np.mean(img, axis=2)
    return (img > threshold).astype(np.float64)


# =============================================================================
# SSIM (Structural Similarity Index)
# =============================================================================

def compute_ssim(
    img1: Union[str, np.ndarray],
    img2: Union[str, np.ndarray],
    window_size: int = 11,
    k1: float = 0.01,
    k2: float = 0.03,
    L: float = 1.0
) -> float:
    """
    Compute SSIM between two images.
    
    Implementation based on the original SSIM paper.
    
    Args:
        img1: First image (path or array)
        img2: Second image (path or array)
        window_size: Size of Gaussian window
        k1, k2: Stability constants
        L: Dynamic range
        
    Returns:
        SSIM value (0-1, higher is better)
    """
    # Load images if paths
    if isinstance(img1, str):
        img1 = load_image_grayscale(img1)
    if isinstance(img2, str):
        img2 = load_image_grayscale(img2)
    
    # Ensure same size
    if img1.shape != img2.shape:
        # Resize img2 to match img1
        img2_pil = Image.fromarray((img2 * 255).astype(np.uint8))
        img2_pil = img2_pil.resize((img1.shape[1], img1.shape[0]), Image.LANCZOS)
        img2 = np.array(img2_pil, dtype=np.float64) / 255.0
    
    # Convert to grayscale if needed
    if len(img1.shape) == 3:
        img1 = np.mean(img1, axis=2)
    if len(img2.shape) == 3:
        img2 = np.mean(img2, axis=2)
    
    c1 = (k1 * L) ** 2
    c2 = (k2 * L) ** 2
    
    # Create Gaussian window
    window = _gaussian_window(window_size)
    
    # Compute means
    mu1 = _convolve2d(img1, window)
    mu2 = _convolve2d(img2, window)
    
    mu1_sq = mu1 ** 2
    mu2_sq = mu2 ** 2
    mu1_mu2 = mu1 * mu2
    
    # Compute variances and covariance
    sigma1_sq = _convolve2d(img1 ** 2, window) - mu1_sq
    sigma2_sq = _convolve2d(img2 ** 2, window) - mu2_sq
    sigma12 = _convolve2d(img1 * img2, window) - mu1_mu2
    
    # SSIM formula
    numerator = (2 * mu1_mu2 + c1) * (2 * sigma12 + c2)
    denominator = (mu1_sq + mu2_sq + c1) * (sigma1_sq + sigma2_sq + c2)
    
    ssim_map = numerator / (denominator + 1e-10)
    
    return float(np.mean(ssim_map))


def _gaussian_window(size: int, sigma: float = 1.5) -> np.ndarray:
    """Create a Gaussian window."""
    coords = np.arange(size) - size // 2
    g = np.exp(-(coords ** 2) / (2 * sigma ** 2))
    window = np.outer(g, g)
    return window / window.sum()


def _convolve2d(img: np.ndarray, kernel: np.ndarray) -> np.ndarray:
    """Simple 2D convolution with padding."""
    try:
        from scipy.ndimage import convolve
        return convolve(img, kernel, mode='reflect')
    except ImportError:
        # Fallback: simple implementation
        from numpy.lib.stride_tricks import sliding_window_view
        
        pad_h = kernel.shape[0] // 2
        pad_w = kernel.shape[1] // 2
        
        padded = np.pad(img, ((pad_h, pad_h), (pad_w, pad_w)), mode='reflect')
        
        # Use sliding window if available
        try:
            windows = sliding_window_view(padded, kernel.shape)
            return np.tensordot(windows, kernel, axes=[[2, 3], [0, 1]])
        except:
            # Very basic fallback
            result = np.zeros_like(img)
            for i in range(img.shape[0]):
                for j in range(img.shape[1]):
                    patch = padded[i:i+kernel.shape[0], j:j+kernel.shape[1]]
                    result[i, j] = np.sum(patch * kernel)
            return result


# =============================================================================
# SILHOUETTE IoU
# =============================================================================

def compute_silhouette_iou(
    img1: Union[str, np.ndarray],
    img2: Union[str, np.ndarray],
    threshold: float = 0.5
) -> float:
    """
    Compute Intersection over Union of silhouettes.
    
    Args:
        img1: First image (path or array)
        img2: Second image (path or array)
        threshold: Binarization threshold
        
    Returns:
        IoU value (0-1, higher is better)
    """
    # Load images if paths
    if isinstance(img1, str):
        img1 = load_image_grayscale(img1)
    if isinstance(img2, str):
        img2 = load_image_grayscale(img2)
    
    # Ensure same size
    if img1.shape != img2.shape:
        img2_pil = Image.fromarray((img2 * 255).astype(np.uint8))
        img2_pil = img2_pil.resize((img1.shape[1], img1.shape[0]), Image.LANCZOS)
        img2 = np.array(img2_pil, dtype=np.float64) / 255.0
    
    # Convert to binary silhouettes
    sil1 = to_silhouette(img1, threshold)
    sil2 = to_silhouette(img2, threshold)
    
    # Compute IoU
    intersection = np.sum(sil1 * sil2)
    union = np.sum(np.maximum(sil1, sil2))
    
    if union == 0:
        return 0.0
    
    return float(intersection / union)


# =============================================================================
# MSE AND PSNR
# =============================================================================

def compute_mse(
    img1: Union[str, np.ndarray],
    img2: Union[str, np.ndarray]
) -> float:
    """
    Compute Mean Squared Error between images.
    
    Args:
        img1: First image
        img2: Second image
        
    Returns:
        MSE value (lower is better)
    """
    if isinstance(img1, str):
        img1 = load_image_grayscale(img1)
    if isinstance(img2, str):
        img2 = load_image_grayscale(img2)
    
    if img1.shape != img2.shape:
        img2_pil = Image.fromarray((img2 * 255).astype(np.uint8))
        img2_pil = img2_pil.resize((img1.shape[1], img1.shape[0]), Image.LANCZOS)
        img2 = np.array(img2_pil, dtype=np.float64) / 255.0
    
    return float(np.mean((img1 - img2) ** 2))


def compute_psnr(
    img1: Union[str, np.ndarray],
    img2: Union[str, np.ndarray],
    max_val: float = 1.0
) -> float:
    """
    Compute Peak Signal-to-Noise Ratio.
    
    Args:
        img1: First image
        img2: Second image
        max_val: Maximum pixel value
        
    Returns:
        PSNR value in dB (higher is better)
    """
    mse = compute_mse(img1, img2)
    
    if mse == 0:
        return float('inf')
    
    return float(10 * np.log10(max_val ** 2 / mse))


# =============================================================================
# F-SCORE (3D Point Cloud)
# =============================================================================

def compute_fscore(
    pc1: np.ndarray,
    pc2: np.ndarray,
    tau: float = 1.0
) -> Tuple[float, float, float]:
    """
    Compute F-score between two point clouds at distance threshold tau.

    Precision = fraction of points in pc1 within tau of any point in pc2.
    Recall    = fraction of points in pc2 within tau of any point in pc1.
    F-score   = 2 * P * R / (P + R).

    Args:
        pc1: Generated point cloud, shape (N, 3)
        pc2: Ground truth point cloud, shape (M, 3)
        tau: Distance threshold (in mesh units, e.g. mm)

    Returns:
        (f_score, precision, recall) - all in [0, 1], higher is better
    """
    from scipy.spatial.distance import cdist

    dist_matrix = cdist(pc1, pc2)

    # Precision: for each point in pc1, is closest point in pc2 within tau?
    min_dist_1_to_2 = np.min(dist_matrix, axis=1)
    precision = float(np.mean(min_dist_1_to_2 <= tau))

    # Recall: for each point in pc2, is closest point in pc1 within tau?
    min_dist_2_to_1 = np.min(dist_matrix, axis=0)
    recall = float(np.mean(min_dist_2_to_1 <= tau))

    if precision + recall == 0:
        return 0.0, 0.0, 0.0

    f_score = 2.0 * precision * recall / (precision + recall)
    return f_score, precision, recall


# =============================================================================
# VOXEL IoU (3D Volumetric)
# =============================================================================

def compute_voxel_iou(
    stl_path_1: str,
    stl_path_2: str,
    pitch: float = 0.5
) -> float:
    """
    Compute volumetric IoU between two meshes by voxelizing them.

    Args:
        stl_path_1: Path to generated STL
        stl_path_2: Path to ground truth STL
        pitch: Voxel size in mesh units (smaller = finer but slower)

    Returns:
        IoU value in [0, 1], higher is better
    """
    import trimesh

    def _load_mesh(path: str) -> Optional['trimesh.Trimesh']:
        mesh = trimesh.load(path)
        if isinstance(mesh, trimesh.Scene):
            meshes = [g for g in mesh.geometry.values()
                      if isinstance(g, trimesh.Trimesh)]
            if not meshes:
                return None
            mesh = trimesh.util.concatenate(meshes)
        if not isinstance(mesh, trimesh.Trimesh):
            return None
        return mesh

    mesh1 = _load_mesh(stl_path_1)
    mesh2 = _load_mesh(stl_path_2)

    if mesh1 is None or mesh2 is None:
        return 0.0

    # Normalize both meshes to a common bounding box so voxel pitch
    # is relative to the combined extent, giving a fair comparison.
    all_points = np.vstack([mesh1.vertices, mesh2.vertices])
    bbox_min = all_points.min(axis=0)
    bbox_max = all_points.max(axis=0)
    extent = (bbox_max - bbox_min).max()

    if extent == 0:
        return 0.0

    # Adaptive pitch: aim for ~64 voxels along the longest axis
    adaptive_pitch = max(pitch, extent / 64.0)

    try:
        vox1 = mesh1.voxelized(adaptive_pitch)
        vox2 = mesh2.voxelized(adaptive_pitch)
    except Exception:
        return 0.0

    # Convert to sets of occupied voxel indices in a common grid
    # Align both to the same origin by computing indices relative to bbox_min
    def _voxel_indices(vox, origin, p):
        points = vox.points  # centers of filled voxels
        indices = np.floor((points - origin) / p).astype(np.int64)
        return set(map(tuple, indices))

    set1 = _voxel_indices(vox1, bbox_min, adaptive_pitch)
    set2 = _voxel_indices(vox2, bbox_min, adaptive_pitch)

    if not set1 and not set2:
        return 0.0

    intersection = len(set1 & set2)
    union = len(set1 | set2)

    if union == 0:
        return 0.0

    return float(intersection / union)


# =============================================================================
# BATCH COMPUTATION
# =============================================================================

def compute_all_metrics(
    img1: Union[str, np.ndarray],
    img2: Union[str, np.ndarray]
) -> dict:
    """
    Compute all metrics between two images.
    
    Args:
        img1: First image
        img2: Second image
        
    Returns:
        Dict with all metrics
    """
    return {
        "ssim": compute_ssim(img1, img2),
        "iou": compute_silhouette_iou(img1, img2),
        "mse": compute_mse(img1, img2),
        "psnr": compute_psnr(img1, img2)
    }


def compute_mean_metrics(metrics_list: list) -> dict:
    """
    Compute mean of metrics across multiple comparisons.
    
    Args:
        metrics_list: List of metric dicts
        
    Returns:
        Dict with mean values
    """
    if not metrics_list:
        return {}
    
    keys = metrics_list[0].keys()
    result = {}
    
    for key in keys:
        values = [m[key] for m in metrics_list if key in m]
        if values:
            # Handle inf values in PSNR
            finite_values = [v for v in values if np.isfinite(v)]
            if finite_values:
                result[f"{key}_mean"] = np.mean(finite_values)
                result[f"{key}_std"] = np.std(finite_values)
            else:
                result[f"{key}_mean"] = float('inf')
                result[f"{key}_std"] = 0.0
    
    return result
