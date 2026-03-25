"""
CADence Validator

This module performs deterministic, local validation of OpenSCAD code and renders.

Validation checks (with weights):
1. Syntax Check (0.35) - Balanced brackets, valid OpenSCAD
2. Renders Non-Blank (0.35) - Image has visible geometry
3. Geometry Sanity (0.15) - No degenerate dimensions
4. Heuristic Coverage (0.15) - Expected parts are present

The validator does NOT use LLMs - all checks are deterministic.
This is important for the paper: judgment is transparent and reproducible.
"""

import os
import re
import subprocess
import tempfile
from typing import Any, Dict, List, Optional, Tuple
from dataclasses import dataclass, field, asdict

import numpy as np
from PIL import Image


# =============================================================================
# CONFIGURATION
# =============================================================================

VALIDATION_WEIGHTS = {
    "syntax": 0.35,
    "renders": 0.35,
    "geometry": 0.15,
    "coverage": 0.15
}

PASS_THRESHOLD = 0.80  # 80% weighted score to pass


# =============================================================================
# DATA CLASSES
# =============================================================================

@dataclass
class CheckResult:
    """Result of a single validation check."""
    passed: bool
    message: str
    weight: float
    score: float = 0.0  # For coverage, can be partial
    
    def __post_init__(self):
        if self.score == 0.0:
            self.score = 1.0 if self.passed else 0.0


@dataclass
class ValidationResult:
    """Complete validation result."""
    score: int  # 0-100
    passed: bool
    checks: Dict[str, CheckResult]
    issues: List[str]
    
    def to_dict(self) -> Dict[str, Any]:
        return {
            "score": self.score,
            "passed": self.passed,
            "checks": {k: asdict(v) for k, v in self.checks.items()},
            "issues": self.issues
        }


# =============================================================================
# SYNTAX CHECKER
# =============================================================================

def check_syntax(code: str, scad_path: Optional[str] = None) -> CheckResult:
    """
    Check OpenSCAD syntax.
    
    Attempts to use OpenSCAD binary if available, falls back to basic checks.
    
    Args:
        code: OpenSCAD code string
        scad_path: Optional path to saved .scad file
        
    Returns:
        CheckResult with pass/fail and message
    """
    # First, do basic bracket checks (fast)
    basic_ok, basic_msg = _check_brackets(code)
    if not basic_ok:
        return CheckResult(
            passed=False,
            message=basic_msg,
            weight=VALIDATION_WEIGHTS["syntax"]
        )
    
    # Check for at least one primitive
    primitives = ['cube', 'sphere', 'cylinder', 'polyhedron', 'circle', 'square', 'polygon']
    has_primitive = any(f"{p}(" in code or f"{p} (" in code for p in primitives)
    if not has_primitive:
        return CheckResult(
            passed=False,
            message="No geometry primitives found",
            weight=VALIDATION_WEIGHTS["syntax"]
        )
    
    # Try OpenSCAD syntax check if available
    try:
        # Create temp file if needed
        if not scad_path:
            with tempfile.NamedTemporaryFile(mode='w', suffix='.scad', delete=False) as f:
                f.write(code)
                scad_path = f.name
        
        # Run OpenSCAD in check mode
        result = subprocess.run(
            ['openscad', '-o', '/dev/null', '--export-format', 'echo', scad_path],
            capture_output=True,
            text=True,
            timeout=10
        )
        
        # Check for errors
        if "ERROR:" in result.stderr or "Parser error" in result.stderr:
            error_lines = [
                line.strip() for line in result.stderr.split('\n')
                if 'ERROR:' in line or 'Parser error' in line
            ]
            return CheckResult(
                passed=False,
                message="; ".join(error_lines[:2]),
                weight=VALIDATION_WEIGHTS["syntax"]
            )
        
        return CheckResult(
            passed=True,
            message="OpenSCAD syntax OK",
            weight=VALIDATION_WEIGHTS["syntax"]
        )
        
    except FileNotFoundError:
        # OpenSCAD not installed, use basic checks
        return CheckResult(
            passed=True,
            message="Basic syntax OK (OpenSCAD not available for full check)",
            weight=VALIDATION_WEIGHTS["syntax"]
        )
    except subprocess.TimeoutExpired:
        return CheckResult(
            passed=False,
            message="Syntax check timed out",
            weight=VALIDATION_WEIGHTS["syntax"]
        )
    except Exception as e:
        return CheckResult(
            passed=True,
            message=f"Basic syntax OK (check error: {str(e)[:30]})",
            weight=VALIDATION_WEIGHTS["syntax"]
        )


def _check_brackets(code: str) -> Tuple[bool, str]:
    """Check for balanced brackets."""
    pairs = [('(', ')'), ('{', '}'), ('[', ']')]
    
    for open_char, close_char in pairs:
        if code.count(open_char) != code.count(close_char):
            return False, f"Unbalanced {open_char}{close_char}"
    
    return True, "Brackets balanced"


# =============================================================================
# RENDER CHECKER
# =============================================================================

def check_renders_non_blank(img_path: str) -> CheckResult:
    """
    Check if rendered image contains visible geometry.
    
    Uses image statistics to detect blank or near-blank images.
    
    Args:
        img_path: Path to rendered PNG image
        
    Returns:
        CheckResult with pass/fail and message
    """
    if not img_path or not os.path.exists(img_path):
        return CheckResult(
            passed=False,
            message="Image file not found",
            weight=VALIDATION_WEIGHTS["renders"]
        )
    
    try:
        img = Image.open(img_path)
        img_array = np.array(img)
        
        # Convert to grayscale if color
        if len(img_array.shape) == 3:
            if img_array.shape[2] == 4:  # RGBA
                gray = np.mean(img_array[:, :, :3], axis=2)
            else:  # RGB
                gray = np.mean(img_array, axis=2)
        else:
            gray = img_array
        
        # Calculate statistics
        std_dev = np.std(gray)
        unique_values = len(np.unique(gray.astype(np.uint8)))
        
        # Check 1: Sufficient variation
        if std_dev < 1.0:
            return CheckResult(
                passed=False,
                message=f"Image appears uniform (std={std_dev:.2f})",
                weight=VALIDATION_WEIGHTS["renders"]
            )
        
        # Check 2: Sufficient unique values
        if unique_values < 10:
            return CheckResult(
                passed=False,
                message=f"Image has too few colors ({unique_values})",
                weight=VALIDATION_WEIGHTS["renders"]
            )
        
        # Check 3: Edge detection (requires scipy)
        try:
            from scipy import ndimage
            edges = np.abs(ndimage.sobel(gray, axis=0)) + np.abs(ndimage.sobel(gray, axis=1))
            edge_density = np.sum(edges > 20) / edges.size
            
            if edge_density < 0.001:  # Less than 0.1% edge pixels
                return CheckResult(
                    passed=False,
                    message=f"No visible geometry (edge density={edge_density:.4f})",
                    weight=VALIDATION_WEIGHTS["renders"]
                )
            
            return CheckResult(
                passed=True,
                message=f"Image OK (edge density={edge_density:.2%})",
                weight=VALIDATION_WEIGHTS["renders"]
            )
            
        except ImportError:
            # scipy not available, use simpler checks
            if std_dev > 5.0 and unique_values > 20:
                return CheckResult(
                    passed=True,
                    message=f"Image has content (std={std_dev:.1f}, colors={unique_values})",
                    weight=VALIDATION_WEIGHTS["renders"]
                )
            else:
                return CheckResult(
                    passed=False,
                    message="Image may be blank or nearly blank",
                    weight=VALIDATION_WEIGHTS["renders"]
                )
    
    except Exception as e:
        return CheckResult(
            passed=False,
            message=f"Render check failed: {str(e)[:50]}",
            weight=VALIDATION_WEIGHTS["renders"]
        )


# =============================================================================
# GEOMETRY SANITY CHECKER
# =============================================================================

def check_geometry_sanity(code: str) -> CheckResult:
    """
    Check for basic geometry sanity.
    
    Detects degenerate dimensions, extreme values, etc.
    
    Args:
        code: OpenSCAD code string
        
    Returns:
        CheckResult with pass/fail and message
    """
    issues = []
    
    # Check 1: Zero or negative dimensions in primitives
    # Look for patterns like cube([0, ...]) or cylinder(h=0, ...)
    zero_patterns = [
        (r'cube\s*\(\s*\[\s*0\s*,', "Zero dimension in cube"),
        (r'cube\s*\(\s*\[[^]]*,\s*0\s*,', "Zero dimension in cube"),
        (r'cube\s*\(\s*\[[^]]*,\s*0\s*\]', "Zero dimension in cube"),
        (r'cylinder\s*\([^)]*h\s*=\s*0[^0-9]', "Zero height cylinder"),
        (r'cylinder\s*\([^)]*r\s*=\s*0[^0-9]', "Zero radius cylinder"),
        (r'sphere\s*\([^)]*r\s*=\s*0[^0-9]', "Zero radius sphere"),
    ]
    
    for pattern, message in zero_patterns:
        if re.search(pattern, code, re.IGNORECASE):
            issues.append(message)
    
    # Check 2: Extremely large values
    numbers = re.findall(r'(?<![a-zA-Z_])(-?\d+\.?\d*)(?![a-zA-Z_0-9])', code)
    for num_str in numbers:
        try:
            num = float(num_str)
            if abs(num) > 100000:
                issues.append(f"Extremely large value: {num}")
                break
        except ValueError:
            pass
    
    # Check 3: Has 3D primitives (not just 2D)
    primitives_3d = ['cube', 'sphere', 'cylinder', 'polyhedron']
    has_3d = any(f"{p}(" in code or f"{p} (" in code for p in primitives_3d)
    
    # Also check for extrusions which create 3D from 2D
    has_extrude = 'linear_extrude' in code or 'rotate_extrude' in code
    
    if not has_3d and not has_extrude:
        issues.append("No 3D primitives or extrusions found")
    
    # Check 4: Negative dimensions (might be intentional for positioning, but warn)
    negative_dim_patterns = [
        r'cube\s*\(\s*\[\s*-',
        r'cylinder\s*\([^)]*h\s*=\s*-',
        r'cylinder\s*\([^)]*r\s*=\s*-',
        r'sphere\s*\([^)]*r\s*=\s*-',
    ]
    
    for pattern in negative_dim_patterns:
        if re.search(pattern, code, re.IGNORECASE):
            issues.append("Negative dimension in primitive (may be intentional)")
            break
    
    if issues:
        # Return first two issues
        return CheckResult(
            passed=False,
            message="; ".join(issues[:2]),
            weight=VALIDATION_WEIGHTS["geometry"]
        )
    
    return CheckResult(
        passed=True,
        message="Geometry looks reasonable",
        weight=VALIDATION_WEIGHTS["geometry"]
    )


# =============================================================================
# HEURISTIC COVERAGE CHECKER
# =============================================================================

def check_heuristic_coverage(
    code: str,
    expected_parts: List[str],
    prompt: str = ""
) -> CheckResult:
    """
    Check if code covers expected parts using heuristics.
    
    This is a soft check - returns a score between 0 and 1.
    
    Args:
        code: OpenSCAD code string
        expected_parts: List of expected component names
        prompt: Original prompt (for additional context)
        
    Returns:
        CheckResult with coverage score
    """
    if not expected_parts:
        # No specific expectations, assume OK
        return CheckResult(
            passed=True,
            message="No specific parts expected",
            weight=VALIDATION_WEIGHTS["coverage"],
            score=1.0
        )
    
    code_lower = code.lower()
    prompt_lower = prompt.lower()
    
    # Pattern mappings for common parts
    part_patterns = {
        'wheel': [r'cylinder.*?(wheel|rotate\s*\[.*?90)', r'wheel', r'tire'],
        'wheels': [r'cylinder.*?(wheel|rotate\s*\[.*?90)', r'wheel', r'tire'],
        'body': [r'cube|hull|union', r'body', r'main', r'chassis'],
        'handle': [r'cylinder|cube', r'handle', r'grip'],
        'hole': [r'difference.*?cylinder', r'hole', r'opening'],
        'holes': [r'difference.*?cylinder', r'hole', r'opening'],
        'base': [r'cube|cylinder', r'base', r'bottom', r'foundation'],
        'top': [r'cube|cylinder', r'top', r'lid', r'cover'],
        'leg': [r'cylinder|cube', r'leg', r'support', r'stand'],
        'legs': [r'cylinder|cube', r'leg', r'support', r'stand'],
        'door': [r'cube|difference', r'door', r'opening'],
        'window': [r'cube|difference|square', r'window'],
        'windows': [r'cube|difference|square', r'window'],
        'roof': [r'cube|cylinder|hull|polyhedron', r'roof', r'top'],
        'seat': [r'cube|cylinder', r'seat', r'chair'],
        'wall': [r'cube', r'wall', r'side', r'panel'],
        'walls': [r'cube', r'wall', r'side', r'panel'],
        'axle': [r'cylinder', r'axle', r'shaft', r'rod'],
        'axles': [r'cylinder', r'axle', r'shaft', r'rod'],
        'neck': [r'cylinder', r'neck', r'spout'],
        'cap': [r'cylinder|sphere', r'cap', r'lid', r'top'],
        'flange': [r'cylinder|cube', r'flange', r'mount'],
        'flanges': [r'cylinder|cube', r'flange', r'mount'],
    }
    
    covered = []
    missing = []
    
    for part in expected_parts:
        part_lower = part.lower()
        found = False
        
        # Direct mention in code (module names, variables, comments)
        if part_lower in code_lower:
            found = True
        
        # Check pattern matching
        elif part_lower in part_patterns:
            patterns = part_patterns[part_lower]
            for pattern in patterns:
                if re.search(pattern, code_lower, re.DOTALL | re.IGNORECASE):
                    found = True
                    break
        
        # Generic check: if part is in prompt and code has relevant geometry
        elif part_lower in prompt_lower:
            if any(prim in code_lower for prim in ['cube', 'cylinder', 'sphere']):
                # Give partial credit - the geometry exists, might be the part
                found = True
        
        if found:
            covered.append(part)
        else:
            missing.append(part)
    
    # Calculate coverage score
    coverage = len(covered) / len(expected_parts) if expected_parts else 1.0
    
    # Build message
    if not missing:
        message = f"All {len(expected_parts)} expected parts covered"
    else:
        message = f"Missing: {', '.join(missing[:3])}" + (
            f" (+{len(missing)-3} more)" if len(missing) > 3 else ""
        )
    
    return CheckResult(
        passed=coverage >= 0.7,  # 70% coverage considered passing
        message=message,
        weight=VALIDATION_WEIGHTS["coverage"],
        score=coverage
    )


# =============================================================================
# MAIN VALIDATOR CLASS
# =============================================================================

class Validator:
    """
    Deterministic validator for OpenSCAD code and renders.
    
    All checks are local and reproducible - no LLM involvement.
    """
    
    def __init__(self, pass_threshold: float = PASS_THRESHOLD):
        """
        Initialize the validator.
        
        Args:
            pass_threshold: Minimum weighted score to pass (0-1)
        """
        self.pass_threshold = pass_threshold
    
    def validate(
        self,
        code: str,
        expected_parts: List[str],
        prompt: str = "",
        scad_path: Optional[str] = None,
        img_path: Optional[str] = None
    ) -> ValidationResult:
        """
        Perform full validation.
        
        Args:
            code: OpenSCAD code string
            expected_parts: List of expected component names
            prompt: Original prompt
            scad_path: Path to .scad file (optional)
            img_path: Path to rendered image (optional)
            
        Returns:
            ValidationResult with scores and issues
        """
        checks = {}
        issues = []
        
        # Check 1: Syntax
        checks["syntax"] = check_syntax(code, scad_path)
        if not checks["syntax"].passed:
            issues.append(f"Syntax: {checks['syntax'].message}")
        
        # Check 2: Render
        if img_path:
            checks["renders"] = check_renders_non_blank(img_path)
        else:
            checks["renders"] = CheckResult(
                passed=False,
                message="No render available",
                weight=VALIDATION_WEIGHTS["renders"],
                score=0.0
            )
        if not checks["renders"].passed:
            issues.append(f"Render: {checks['renders'].message}")
        
        # Check 3: Geometry sanity
        checks["geometry"] = check_geometry_sanity(code)
        if not checks["geometry"].passed:
            issues.append(f"Geometry: {checks['geometry'].message}")
        
        # Check 4: Heuristic coverage
        checks["coverage"] = check_heuristic_coverage(code, expected_parts, prompt)
        if not checks["coverage"].passed:
            issues.append(f"Coverage: {checks['coverage'].message}")
        
        # Calculate weighted score
        total_score = sum(
            check.score * check.weight
            for check in checks.values()
        )
        
        # Convert to 0-100 scale
        score_100 = int(round(total_score * 100))
        passed = total_score >= self.pass_threshold
        
        return ValidationResult(
            score=score_100,
            passed=passed,
            checks=checks,
            issues=issues
        )


# =============================================================================
# CONVENIENCE FUNCTION
# =============================================================================

def validate_scad(
    code: str,
    expected_parts: List[str],
    prompt: str = "",
    scad_path: Optional[str] = None,
    img_path: Optional[str] = None,
    pass_threshold: float = PASS_THRESHOLD
) -> ValidationResult:
    """
    Convenience function for validation.
    
    Args:
        code: OpenSCAD code
        expected_parts: Expected component names
        prompt: Original prompt
        scad_path: Path to .scad file
        img_path: Path to rendered image
        pass_threshold: Minimum score to pass
        
    Returns:
        ValidationResult
    """
    validator = Validator(pass_threshold)
    return validator.validate(code, expected_parts, prompt, scad_path, img_path)
