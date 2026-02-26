"""
CADence Repair Module

This module handles targeted repair of OpenSCAD code based on validation issues.

Key features:
- Issue-specific repair prompts
- Preserves original design intent
- Limited attempts to prevent infinite loops
- Optional human hints for manual refinement
- KB-aware repair with visual verification (NopSCADlib components)
"""

import json
import re
from pathlib import Path
from typing import Any, Dict, List, Optional
from dataclasses import dataclass, field

from .compiler import strip_to_scad
from .validator import ValidationResult

# KB integration (optional)
try:
    from ..kb import (
        VisualVerifier,
        VerificationResult,
        get_component_images,
        is_kb_ready
    )
    KB_AVAILABLE = True
except ImportError:
    KB_AVAILABLE = False
    VerificationResult = None


# =============================================================================
# CONFIGURATION
# =============================================================================

MAX_REPAIR_ATTEMPTS = 2


# =============================================================================
# PROMPTS
# =============================================================================

REPAIR_SYSTEM_PROMPT = """You are an OpenSCAD CODE REPAIR expert. Fix the code based on the identified issues.

REPAIR GUIDELINES:
1. Address EACH issue in the validation report
2. Preserve the original design intent
3. Maintain parametric structure (keep variables, don't hardcode)
4. Ensure the code will render without errors

COMMON FIXES:
- Syntax errors: Fix brackets, semicolons, function calls
- Zero dimensions: Add minimum values or fix calculations
- Missing parts: Add the geometry for missing components
- Blank render: Ensure geometry is positioned in view, check for boolean errors

OUTPUT: Only corrected OpenSCAD code. No explanations, no markdown."""


REPAIR_USER_TEMPLATE = """Fix this OpenSCAD code.

ORIGINAL REQUEST: {prompt}

CURRENT CODE:
```
{code}
```

VALIDATION ISSUES:
{issues}

{hint_section}

Generate the corrected OpenSCAD code that addresses all issues."""


HINT_TEMPLATE = """USER FEEDBACK:
{hint}

Incorporate this feedback into your fix."""


KB_REPAIR_SYSTEM_PROMPT = """You are an OpenSCAD CODE REPAIR expert specializing in accurate component reproduction.

You have access to EXACT component definitions from the NopSCADlib knowledge base. Your job is to fix the code so it produces OUTPUT IDENTICAL to the reference images.

CRITICAL REQUIREMENTS:
1. Use the EXACT module code provided from the knowledge base
2. Match the reference image structure precisely
3. Do not modify the KB component modules - use them as-is
4. Fix positioning, scaling, and integration issues
5. The generated render MUST match the KB reference images

OUTPUT: Only corrected OpenSCAD code. No explanations."""


KB_REPAIR_USER_TEMPLATE = """Fix this OpenSCAD code to match the knowledge base reference.

ORIGINAL REQUEST: {prompt}

## KNOWLEDGE BASE COMPONENT (use this EXACT code):
```openscad
{kb_module_code}
```

## CURRENT CODE:
```openscad
{code}
```

## VALIDATION ISSUES:
{issues}

## VISUAL VERIFICATION RESULT:
{visual_feedback}

## REQUIRED CHANGES:
{repair_suggestions}

Generate corrected OpenSCAD code that:
1. Uses the exact KB module definition
2. Matches the reference image visually
3. Fixes all validation issues"""


# =============================================================================
# REPAIR CLASS
# =============================================================================

@dataclass
class RepairResult:
    """Result of a repair attempt."""
    code: str
    success: bool
    message: str
    attempt: int
    # KB-specific fields
    kb_verified: bool = False
    kb_verification_score: float = 0.0
    kb_repair_suggestions: List[str] = field(default_factory=list)


class CodeRepairer:
    """Repairs OpenSCAD code based on validation feedback."""
    
    def __init__(self, client, model: str = "gpt-4o"):
        """
        Initialize the repairer.
        
        Args:
            client: OpenAI client instance
            model: Model to use for repair
        """
        self.client = client
        self.model = model
    
    def repair(
        self,
        code: str,
        validation: ValidationResult,
        prompt: str,
        user_hint: str = "",
        plan: Optional[Dict[str, Any]] = None
    ) -> RepairResult:
        """
        Attempt to repair code based on validation issues.
        
        Args:
            code: Current OpenSCAD code
            validation: Validation result with issues
            prompt: Original design prompt
            user_hint: Optional user feedback for guided repair
            plan: Optional JSON CAD plan for reference
            
        Returns:
            RepairResult with repaired code
        """
        # Build issues string
        issues_str = self._format_issues(validation)
        
        # Build hint section
        hint_section = ""
        if user_hint:
            hint_section = HINT_TEMPLATE.format(hint=user_hint)
        
        # Build user message
        user_content = REPAIR_USER_TEMPLATE.format(
            prompt=prompt,
            code=code[:3000],  # Limit code length
            issues=issues_str,
            hint_section=hint_section
        )
        
        # Add plan context if available
        if plan:
            user_content += f"\n\nREFERENCE PLAN:\n{json.dumps(plan, indent=2)[:1000]}"
        
        try:
            response = self.client.chat.completions.create(
                model=self.model,
                temperature=0.1,
                messages=[
                    {"role": "system", "content": REPAIR_SYSTEM_PROMPT},
                    {"role": "user", "content": user_content}
                ]
            )
            
            repaired_code = strip_to_scad(response.choices[0].message.content)
            
            # Basic sanity check
            if len(repaired_code) < 10:
                return RepairResult(
                    code=code,
                    success=False,
                    message="Repair produced empty or minimal code",
                    attempt=1
                )
            
            return RepairResult(
                code=repaired_code,
                success=True,
                message="Code repaired",
                attempt=1
            )
            
        except Exception as e:
            return RepairResult(
                code=code,
                success=False,
                message=f"Repair failed: {str(e)[:50]}",
                attempt=1
            )

    def repair_with_kb(
        self,
        code: str,
        validation: ValidationResult,
        prompt: str,
        kb_module_code: str,
        visual_feedback: str = "",
        repair_suggestions: List[str] = None
    ) -> RepairResult:
        """
        Repair code using knowledge base context for accurate component reproduction.

        Args:
            code: Current OpenSCAD code
            validation: Validation result with issues
            prompt: Original design prompt
            kb_module_code: Exact module code from KB to use
            visual_feedback: Feedback from visual verification
            repair_suggestions: Specific repair suggestions from verifier

        Returns:
            RepairResult with KB-aware repaired code
        """
        if not KB_AVAILABLE:
            # Fall back to regular repair
            return self.repair(code, validation, prompt)

        repair_suggestions = repair_suggestions or []

        # Build issues string
        issues_str = self._format_issues(validation)

        # Build visual feedback
        visual_str = visual_feedback if visual_feedback else "No visual verification performed yet"

        # Build repair suggestions
        suggestions_str = "\n".join(f"- {s}" for s in repair_suggestions) if repair_suggestions else "None"

        # Build user message
        user_content = KB_REPAIR_USER_TEMPLATE.format(
            prompt=prompt,
            kb_module_code=kb_module_code[:2000],
            code=code[:2500],
            issues=issues_str,
            visual_feedback=visual_str,
            repair_suggestions=suggestions_str
        )

        try:
            response = self.client.chat.completions.create(
                model=self.model,
                temperature=0.1,
                messages=[
                    {"role": "system", "content": KB_REPAIR_SYSTEM_PROMPT},
                    {"role": "user", "content": user_content}
                ]
            )

            repaired_code = strip_to_scad(response.choices[0].message.content)

            # Basic sanity check
            if len(repaired_code) < 10:
                return RepairResult(
                    code=code,
                    success=False,
                    message="KB repair produced empty or minimal code",
                    attempt=1,
                    kb_repair_suggestions=repair_suggestions
                )

            return RepairResult(
                code=repaired_code,
                success=True,
                message="Code repaired with KB context",
                attempt=1,
                kb_repair_suggestions=repair_suggestions
            )

        except Exception as e:
            return RepairResult(
                code=code,
                success=False,
                message=f"KB repair failed: {str(e)[:50]}",
                attempt=1,
                kb_repair_suggestions=repair_suggestions
            )

    def _format_issues(self, validation: ValidationResult) -> str:
        """Format validation issues for the repair prompt."""
        lines = []
        
        # Add overall score
        lines.append(f"Overall Score: {validation.score}/100 (threshold: 80)")
        lines.append("")
        
        # Add individual check results
        for check_name, check_result in validation.checks.items():
            status = "✓ PASS" if check_result.passed else "✗ FAIL"
            lines.append(f"{check_name.upper()}: {status}")
            lines.append(f"  Message: {check_result.message}")
            lines.append(f"  Weight: {check_result.weight:.0%}")
            lines.append("")
        
        # Add issue summary
        if validation.issues:
            lines.append("ISSUES TO FIX:")
            for i, issue in enumerate(validation.issues, 1):
                lines.append(f"  {i}. {issue}")
        
        return "\n".join(lines)


# =============================================================================
# SPECIFIC REPAIR STRATEGIES
# =============================================================================

def quick_syntax_fix(code: str) -> str:
    """
    Attempt quick syntax fixes without LLM.
    
    Handles common issues like:
    - Missing semicolons
    - Unbalanced brackets
    - Common typos
    """
    fixed = code
    
    # Fix common typos
    typos = {
        'cyliner': 'cylinder',
        'shere': 'sphere',
        'cubes': 'cube',
        'translat(': 'translate(',
        'rotat(': 'rotate(',
    }
    for wrong, right in typos.items():
        fixed = fixed.replace(wrong, right)
    
    # Ensure statements end with semicolons (simple heuristic)
    lines = fixed.split('\n')
    fixed_lines = []
    for line in lines:
        stripped = line.rstrip()
        # If line ends with ) and not ){ or ); add semicolon
        if stripped.endswith(')') and not stripped.endswith(');') and not stripped.endswith('){'):
            # Check if next non-empty line starts with { (then don't add semicolon)
            stripped += ';'
        fixed_lines.append(stripped)
    
    return '\n'.join(fixed_lines)


def fix_zero_dimensions(code: str) -> str:
    """
    Replace zero dimensions with small positive values.
    """
    # Replace h=0 with h=0.01
    code = re.sub(r'h\s*=\s*0([^0-9.])', r'h=0.01\1', code)
    # Replace r=0 with r=0.01
    code = re.sub(r'r\s*=\s*0([^0-9.])', r'r=0.01\1', code)
    
    return code


# =============================================================================
# REPAIR ORCHESTRATOR
# =============================================================================

class RepairOrchestrator:
    """
    Orchestrates the repair process with multiple attempts.
    """
    
    def __init__(
        self,
        client,
        model: str = "gpt-4o",
        max_attempts: int = MAX_REPAIR_ATTEMPTS
    ):
        """
        Initialize the orchestrator.
        
        Args:
            client: OpenAI client
            model: Model to use
            max_attempts: Maximum repair attempts
        """
        self.repairer = CodeRepairer(client, model)
        self.max_attempts = max_attempts
    
    def repair_until_valid(
        self,
        code: str,
        validate_fn,  # Callable that returns ValidationResult
        prompt: str,
        expected_parts: List[str],
        user_hint: str = "",
        plan: Optional[Dict[str, Any]] = None
    ) -> tuple:
        """
        Attempt repairs until validation passes or max attempts reached.
        
        Args:
            code: Initial code
            validate_fn: Validation function
            prompt: Original prompt
            expected_parts: Expected parts for validation
            user_hint: Optional user hint
            plan: Optional CAD plan
            
        Returns:
            Tuple of (final_code, final_validation, attempt_count)
        """
        current_code = code
        attempt = 0
        
        while attempt < self.max_attempts:
            # Validate current code
            validation = validate_fn(current_code, expected_parts, prompt)
            
            if validation.passed:
                return current_code, validation, attempt
            
            # Try quick fixes first (no LLM)
            if attempt == 0:
                quick_fixed = quick_syntax_fix(current_code)
                quick_fixed = fix_zero_dimensions(quick_fixed)
                
                if quick_fixed != current_code:
                    quick_validation = validate_fn(quick_fixed, expected_parts, prompt)
                    if quick_validation.score > validation.score:
                        current_code = quick_fixed
                        validation = quick_validation
                        if validation.passed:
                            return current_code, validation, attempt
            
            # LLM-based repair
            attempt += 1
            result = self.repairer.repair(
                current_code,
                validation,
                prompt,
                user_hint if attempt == 1 else "",  # Only use hint on first repair
                plan
            )
            
            if result.success:
                current_code = result.code
            else:
                # Repair failed, return what we have
                break
        
        # Final validation
        final_validation = validate_fn(current_code, expected_parts, prompt)
        return current_code, final_validation, attempt

    def repair_with_kb_verification(
        self,
        code: str,
        validate_fn,
        prompt: str,
        expected_parts: List[str],
        kb_components: List[Any],  # List of KBComponentContext
        generated_images: Dict[str, Path],
        user_hint: str = "",
        plan: Optional[Dict[str, Any]] = None
    ) -> tuple:
        """
        Repair with KB visual verification loop.

        This method:
        1. Validates the code (syntax, render)
        2. Verifies against KB reference images
        3. Repairs using KB context until both pass

        Args:
            code: Initial code
            validate_fn: Validation function
            prompt: Original prompt
            expected_parts: Expected parts
            kb_components: List of KBComponentContext from design brief
            generated_images: Dict of view → path for generated images
            user_hint: Optional user hint
            plan: Optional CAD plan

        Returns:
            Tuple of (final_code, final_validation, kb_verification_results, attempt_count)
        """
        if not KB_AVAILABLE or not kb_components:
            # Fall back to regular repair
            code, validation, attempts = self.repair_until_valid(
                code, validate_fn, prompt, expected_parts, user_hint, plan
            )
            return code, validation, None, attempts

        current_code = code
        attempt = 0
        kb_verification_results = []
        verifier = VisualVerifier()

        while attempt < self.max_attempts:
            # Step 1: Standard validation
            validation = validate_fn(current_code, expected_parts, prompt)

            if not validation.passed:
                # Standard repair first
                attempt += 1
                result = self.repairer.repair(
                    current_code, validation, prompt, user_hint if attempt == 1 else "", plan
                )
                if result.success:
                    current_code = result.code
                continue

            # Step 2: KB visual verification for each KB component
            all_kb_passed = True
            kb_results = []

            for kb_comp in kb_components:
                # Get reference images for this component
                ref_images = get_component_images(kb_comp.component_id)
                if not ref_images:
                    continue

                # Verify against reference
                verification = verifier.verify_component(
                    component_id=kb_comp.component_id,
                    component_name=kb_comp.component_name,
                    generated_images=generated_images,
                    reference_images=ref_images
                )
                kb_results.append(verification)

                if not verification.overall_passed:
                    all_kb_passed = False

            kb_verification_results = kb_results

            if all_kb_passed:
                # Both validation and KB verification passed
                return current_code, validation, kb_verification_results, attempt

            # Step 3: KB-aware repair
            attempt += 1

            # Find the worst failing KB component
            worst_result = min(kb_results, key=lambda r: r.overall_score) if kb_results else None

            if worst_result:
                # Get the KB module code for repair context
                kb_module_code = next(
                    (c.module_code for c in kb_components if c.component_id == worst_result.component_id),
                    ""
                )

                visual_feedback = worst_result.get_summary()
                repair_suggestions = worst_result.repair_suggestions

                result = self.repairer.repair_with_kb(
                    current_code,
                    validation,
                    prompt,
                    kb_module_code,
                    visual_feedback,
                    repair_suggestions
                )

                if result.success:
                    current_code = result.code

        # Final validation
        final_validation = validate_fn(current_code, expected_parts, prompt)
        return current_code, final_validation, kb_verification_results, attempt


# =============================================================================
# CONVENIENCE FUNCTIONS
# =============================================================================

def repair_code(
    client,
    code: str,
    validation: ValidationResult,
    prompt: str,
    user_hint: str = "",
    model: str = "gpt-4o"
) -> RepairResult:
    """
    Convenience function for single repair attempt.
    
    Args:
        client: OpenAI client
        code: Code to repair
        validation: Validation result
        prompt: Original prompt
        user_hint: Optional user hint
        model: Model to use
        
    Returns:
        RepairResult
    """
    repairer = CodeRepairer(client, model)
    return repairer.repair(code, validation, prompt, user_hint)
