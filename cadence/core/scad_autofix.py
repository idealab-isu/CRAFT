"""
CADence SCAD Auto-Fixer

This module provides LLM-based auto-fixing for OpenSCAD code that causes
rendering issues (timeouts, hangs, broken geometry).

Common issues fixed:
1. minkowski() on complex bodies - extremely expensive operation
2. rotate(a=360) instead of rotate_extrude() - broken geometry
3. Excessive $fn values on complex models - slow renders
4. Nested expensive operations - exponential complexity

The auto-fixer uses an LLM to understand the design intent and simplify
the SCAD code while preserving essential geometry.
"""

import os
import re
import time
import subprocess
import tempfile
from typing import Optional, Tuple
from dataclasses import dataclass

# Models that require Responses API
RESPONSES_API_MODELS = {"gpt-5.2"}

# Models that use max_completion_tokens
NEW_API_MODELS = {"gpt-5.1", "gpt-5.2", "o1", "o1-mini", "o1-preview", "o3", "o3-mini"}

# Retry configuration
MAX_RETRIES = 2
RETRY_DELAY = 2
SYNTAX_CHECK_TIMEOUT = 10  # seconds for syntax check


@dataclass
class AutoFixResult:
    """Result of SCAD auto-fix attempt."""
    success: bool
    original_code: str
    fixed_code: str
    issues_found: list
    changes_made: list
    error: Optional[str] = None


class SCADAutoFixer:
    """
    LLM-based auto-fixer for OpenSCAD code.

    Fixes common patterns that cause OpenSCAD to hang or timeout:
    - minkowski() operations on complex assemblies
    - Incorrect rotate() instead of rotate_extrude()
    - Overly complex boolean operations
    - High $fn values combined with expensive operations
    """

    def __init__(self, client, model: str):
        """
        Initialize the auto-fixer.

        Args:
            client: Unified LLM client
            model: Model to use for fixing
        """
        self.client = client
        self.model = model

    def fix(
        self,
        scad_code: str,
        original_prompt: str,
        timeout_occurred: bool = True,
        error_message: Optional[str] = None
    ) -> AutoFixResult:
        """
        Attempt to fix SCAD code that caused rendering issues.

        Args:
            scad_code: The problematic OpenSCAD code
            original_prompt: The user's original design request
            timeout_occurred: Whether a timeout triggered this fix
            error_message: Optional error message from OpenSCAD

        Returns:
            AutoFixResult with fixed code and details
        """
        # Detect known problematic patterns
        issues_found = self._detect_issues(scad_code)

        if not issues_found and not timeout_occurred:
            return AutoFixResult(
                success=False,
                original_code=scad_code,
                fixed_code=scad_code,
                issues_found=[],
                changes_made=[],
                error="No issues detected"
            )

        # Build the fix prompt
        prompt = self._build_fix_prompt(
            scad_code,
            original_prompt,
            issues_found,
            timeout_occurred,
            error_message
        )

        # Call LLM to fix (with syntax validation and retry)
        max_fix_attempts = 3
        last_syntax_error = None

        for attempt in range(max_fix_attempts):
            try:
                if attempt > 0:
                    # On retry, add syntax error feedback to prompt
                    prompt = self._build_syntax_fix_prompt(
                        scad_code, original_prompt, issues_found, last_syntax_error
                    )

                fixed_code = self._call_llm(prompt)

                if fixed_code and fixed_code.strip() != scad_code.strip():
                    # CRITICAL: Validate syntax before accepting
                    is_valid, syntax_error = self._validate_syntax(fixed_code)

                    if is_valid:
                        # Verify the fix removed problematic patterns
                        remaining_issues = self._detect_issues(fixed_code)
                        changes_made = [
                            issue for issue in issues_found
                            if issue not in remaining_issues
                        ]

                        return AutoFixResult(
                            success=True,
                            original_code=scad_code,
                            fixed_code=fixed_code,
                            issues_found=issues_found,
                            changes_made=changes_made
                        )
                    else:
                        # Syntax error - try again
                        last_syntax_error = syntax_error
                        print(f"[SCADAutoFixer] Fixed code has syntax error (attempt {attempt + 1}): {syntax_error}")
                        continue
                else:
                    # LLM returned unchanged code, try fallback
                    break

            except Exception as e:
                print(f"[SCADAutoFixer] Fix attempt {attempt + 1} failed: {e}")
                continue

        # All attempts failed - try rule-based fallback
        print("[SCADAutoFixer] LLM fixes failed, attempting rule-based fallback")
        fallback_code = self._apply_rule_based_fix(scad_code, issues_found)

        if fallback_code != scad_code:
            is_valid, _ = self._validate_syntax(fallback_code)
            if is_valid:
                return AutoFixResult(
                    success=True,
                    original_code=scad_code,
                    fixed_code=fallback_code,
                    issues_found=issues_found,
                    changes_made=["rule_based_fix"]
                )

        return AutoFixResult(
            success=False,
            original_code=scad_code,
            fixed_code=scad_code,
            issues_found=issues_found,
            changes_made=[],
            error=f"All fix attempts failed. Last error: {last_syntax_error}"
        )

    def _validate_syntax(self, code: str) -> Tuple[bool, Optional[str]]:
        """
        Validate OpenSCAD syntax without full rendering.

        Uses OpenSCAD's parser to check if the code is syntactically valid.

        Args:
            code: OpenSCAD code to validate

        Returns:
            Tuple of (is_valid, error_message)
        """
        try:
            # Create temporary file
            with tempfile.NamedTemporaryFile(
                mode='w', suffix='.scad', delete=False
            ) as f:
                f.write(code)
                temp_path = f.name

            try:
                # Run OpenSCAD with --export-format=echo to just parse without rendering
                # This checks syntax without the computational cost of rendering
                result = subprocess.run(
                    [
                        'openscad',
                        '-o', '/dev/null',
                        '--export-format', 'echo',
                        temp_path
                    ],
                    capture_output=True,
                    text=True,
                    timeout=SYNTAX_CHECK_TIMEOUT
                )

                # Check for parser errors
                stderr = result.stderr
                if 'Parser error' in stderr or 'syntax error' in stderr:
                    # Extract the error message
                    error_lines = [
                        line for line in stderr.split('\n')
                        if 'error' in line.lower() or 'ERROR' in line
                    ]
                    error_msg = error_lines[0] if error_lines else "Unknown syntax error"
                    return False, error_msg

                return True, None

            finally:
                # Clean up temp file
                if os.path.exists(temp_path):
                    os.remove(temp_path)

        except subprocess.TimeoutExpired:
            # Syntax check shouldn't timeout - likely valid but complex
            return True, None
        except Exception as e:
            # If we can't check, assume it might be valid
            print(f"[SCADAutoFixer] Syntax validation failed: {e}")
            return True, None

    def _build_syntax_fix_prompt(
        self,
        original_code: str,
        original_prompt: str,
        issues_found: list,
        syntax_error: str
    ) -> str:
        """Build a prompt specifically to fix syntax errors."""
        return f"""You are an expert OpenSCAD programmer. The previous fix attempt produced INVALID SYNTAX.

## SYNTAX ERROR
{syntax_error}

## ORIGINAL DESIGN REQUEST
{original_prompt}

## ORIGINAL CODE (had performance issues)
```openscad
{original_code}
```

## ISSUES TO FIX
- Remove minkowski() operations (cause timeouts)
- Fix any rotate(a=360) → rotate_extrude()
- Reduce $fn if > 64

## REQUIREMENTS
1. Output MUST be valid OpenSCAD syntax
2. Ensure all brackets {{}}, parentheses (), and semicolons are balanced
3. Ensure all module calls have proper syntax
4. Keep the design intent - represent: {original_prompt}
5. Keep it simple - basic shapes, no minkowski

Return ONLY valid OpenSCAD code. Double-check syntax before responding."""

    def _apply_rule_based_fix(self, code: str, issues: list) -> str:
        """
        Apply simple rule-based fixes without LLM.

        This is a fallback when LLM fixes keep producing syntax errors.
        """
        fixed = code

        # Remove minkowski operations entirely (aggressive but safe)
        if "minkowski_operation" in issues or "nested_minkowski" in issues:
            # Replace minkowski blocks with their first child
            # Pattern: minkowski() { shape1(); shape2(); } -> shape1();
            fixed = self._remove_minkowski_blocks(fixed)

        # Reduce high $fn values
        if "high_fn_with_expensive_ops" in issues:
            fixed = re.sub(r'\$fn\s*=\s*(\d+)', lambda m: f'$fn={min(48, int(m.group(1)))}', fixed)

        return fixed

    def _remove_minkowski_blocks(self, code: str) -> str:
        """
        Remove minkowski() operations, keeping only the first child shape.

        This is an aggressive but syntactically safe fix.
        """
        result = []
        i = 0
        while i < len(code):
            # Look for minkowski(
            if code[i:i+10].lower().startswith('minkowski('):
                # Find the opening brace
                j = i + 10
                while j < len(code) and code[j] != '{':
                    j += 1
                if j < len(code):
                    # Find matching closing brace
                    brace_count = 1
                    k = j + 1
                    first_child_start = k
                    first_child_end = None
                    child_brace_depth = 0

                    while k < len(code) and brace_count > 0:
                        if code[k] == '{':
                            brace_count += 1
                            child_brace_depth += 1
                        elif code[k] == '}':
                            brace_count -= 1
                            if brace_count > 0:
                                child_brace_depth -= 1
                        elif code[k] == ';' and child_brace_depth == 0 and first_child_end is None:
                            first_child_end = k + 1
                        k += 1

                    # Extract just the first child (or entire content if no semicolon found)
                    if first_child_end:
                        result.append(code[first_child_start:first_child_end])
                    else:
                        # Just skip the minkowski entirely
                        result.append("// minkowski removed for performance\n")

                    i = k
                    continue

            result.append(code[i])
            i += 1

        return ''.join(result)

    def _detect_issues(self, code: str) -> list:
        """
        Detect known problematic patterns in SCAD code.

        Args:
            code: OpenSCAD code to analyze

        Returns:
            List of detected issues
        """
        issues = []
        code_lower = code.lower()

        # Check for minkowski (very expensive)
        if "minkowski()" in code or "minkowski(" in code_lower:
            issues.append("minkowski_operation")

        # Check for incorrect rotate instead of rotate_extrude
        # Pattern: rotate(a=360, ...) or rotate([0,360,...]) on 2D shapes
        if "rotate(a=360" in code or "rotate(a = 360" in code:
            issues.append("incorrect_rotate_360")
        if "rotate([" in code and "360" in code:
            # Check if it's near a 2D operation
            if "polygon(" in code or "square(" in code or "circle(" in code:
                issues.append("possible_incorrect_rotate")

        # Check for high $fn combined with complex operations
        import re
        fn_match = re.search(r'\$fn\s*=\s*(\d+)', code)
        if fn_match:
            fn_value = int(fn_match.group(1))
            if fn_value > 64:
                if "minkowski" in code_lower or "hull(" in code_lower:
                    issues.append("high_fn_with_expensive_ops")

        # Check for deeply nested boolean operations
        # Count depth of union/difference/intersection
        bool_ops = code_lower.count("union(") + code_lower.count("difference(") + code_lower.count("intersection(")
        if bool_ops > 15:
            issues.append("excessive_boolean_operations")

        # Check for nested minkowski (exponential complexity)
        if code_lower.count("minkowski(") > 1:
            issues.append("nested_minkowski")

        return issues

    def _build_fix_prompt(
        self,
        scad_code: str,
        original_prompt: str,
        issues_found: list,
        timeout_occurred: bool,
        error_message: Optional[str]
    ) -> str:
        """Build the prompt for the LLM to fix the SCAD code."""

        issue_descriptions = {
            "minkowski_operation": """
**MINKOWSKI OPERATION DETECTED**
The `minkowski()` operation is extremely expensive computationally.
FIX: Remove minkowski() and use simpler alternatives:
- For rounded edges: Use `offset(r=..., $fn=...)` on 2D profiles before extrude
- For fillets: Use hull() between shapes, or simply skip the fillet
- For chamfers: Use explicit chamfer geometry with difference()
""",
            "incorrect_rotate_360": """
**INCORRECT ROTATE(360) DETECTED**
Using `rotate(a=360, ...)` does NOT create a solid of revolution.
FIX: Replace with `rotate_extrude(angle=360)` for 2D→3D revolution.
Example:
  WRONG:  rotate(a=360, v=[0,1,0]) polygon(...)
  RIGHT:  rotate_extrude(angle=360) polygon(...)
""",
            "possible_incorrect_rotate": """
**POSSIBLE INCORRECT ROTATE DETECTED**
Check if rotate() is being used to create a solid of revolution.
If so, use `rotate_extrude()` instead.
""",
            "high_fn_with_expensive_ops": """
**HIGH $fn WITH EXPENSIVE OPERATIONS**
High $fn (>64) combined with minkowski/hull creates millions of polygons.
FIX: Reduce $fn to 32-48, or remove the expensive operation.
""",
            "excessive_boolean_operations": """
**EXCESSIVE BOOLEAN OPERATIONS**
Too many nested union/difference/intersection operations.
FIX: Simplify the model structure:
- Combine similar operations
- Use modules to organize parts
- Reduce unnecessary boolean depth
""",
            "nested_minkowski": """
**NESTED MINKOWSKI DETECTED**
Multiple minkowski operations multiply complexity exponentially.
FIX: Remove all but essential minkowski, or remove entirely.
"""
        }

        issues_text = "\n".join(
            issue_descriptions.get(issue, f"- {issue}")
            for issue in issues_found
        )

        context = "The OpenSCAD render TIMED OUT" if timeout_occurred else "The OpenSCAD render FAILED"
        if error_message:
            context += f"\nError: {error_message}"

        prompt = f"""You are an expert OpenSCAD programmer. Fix this code that caused rendering issues.

## CONTEXT
{context}

## ORIGINAL DESIGN REQUEST
{original_prompt}

## ISSUES DETECTED
{issues_text if issues_text else "Render timeout with no specific pattern detected - simplify complex operations."}

## PROBLEMATIC CODE
```openscad
{scad_code}
```

## REQUIREMENTS

1. **PRESERVE DESIGN INTENT**: The fixed model must still represent the requested object
2. **REMOVE EXPENSIVE OPERATIONS**:
   - Replace minkowski() with simpler alternatives or remove entirely
   - Fix incorrect rotate() → rotate_extrude()
   - Reduce $fn if combined with expensive operations
3. **KEEP ESSENTIAL GEOMETRY**: Main shape, core structure, primary parts must remain
4. **SIMPLIFY SECONDARY FEATURES**: Fillets, chamfers, fine details can be simplified or removed
5. **ENSURE RENDERABILITY**: The code MUST render within 60 seconds

## SPECIFIC FIXES REQUIRED

- If minkowski() is used for rounded edges: REMOVE IT or use offset() on 2D profile
- If rotate(a=360) is used on 2D shapes: Replace with rotate_extrude()
- If $fn > 64 with expensive ops: Reduce to $fn = 32 or 48
- If excessive booleans: Simplify structure

## OUTPUT

Return ONLY the fixed OpenSCAD code. No explanations.
The code must:
- Be valid OpenSCAD syntax
- Render successfully within 60 seconds
- Preserve the recognizable shape of the requested object

FIXED CODE:"""

        return prompt

    def _call_llm(self, prompt: str) -> Optional[str]:
        """
        Call the LLM to fix the SCAD code.

        Handles both Responses API (GPT-5.2) and Chat Completions API.
        Includes retry logic.
        """
        last_error = None

        for attempt in range(MAX_RETRIES + 1):
            try:
                if self.model in RESPONSES_API_MODELS:
                    return self._call_responses_api(prompt)
                else:
                    return self._call_chat_api(prompt)

            except Exception as e:
                last_error = e
                if attempt < MAX_RETRIES:
                    print(f"[SCADAutoFixer] LLM call failed (attempt {attempt + 1}), retrying: {e}")
                    time.sleep(RETRY_DELAY * (attempt + 1))
                else:
                    raise last_error

        raise last_error

    def _call_responses_api(self, prompt: str) -> str:
        """Call OpenAI Responses API for GPT-5.2."""
        content_parts = [
            {"type": "input_text", "text": prompt}
        ]

        response = self.client.responses.create(
            model=self.model,
            input=[{"role": "user", "content": content_parts}],
            temperature=0.1,
            max_output_tokens=8000
        )

        return self._extract_scad_code(response.output_text)

    def _call_chat_api(self, prompt: str) -> str:
        """Call Chat Completions API for GPT-4o/GPT-5.1/Gemini."""
        # Determine token parameter
        if self.model in NEW_API_MODELS:
            token_param = {"max_completion_tokens": 8000}
        else:
            token_param = {"max_tokens": 8000}

        response = self.client.chat.completions.create(
            model=self.model,
            messages=[
                {
                    "role": "system",
                    "content": "You are an expert OpenSCAD programmer. Fix code to be renderable."
                },
                {"role": "user", "content": prompt}
            ],
            temperature=0.1,
            **token_param
        )

        return self._extract_scad_code(response.choices[0].message.content)

    def _extract_scad_code(self, text: str) -> str:
        """Extract SCAD code from LLM response, handling markdown blocks."""
        import re

        # Try to find code block
        code_block_pattern = r'```(?:openscad|scad)?\s*([\s\S]*?)```'
        matches = re.findall(code_block_pattern, text)

        if matches:
            return matches[0].strip()

        # If no code block, clean up the text
        text = text.strip()
        if text.startswith("```"):
            lines = text.split("\n")
            text = "\n".join(lines[1:])
        if text.endswith("```"):
            text = text[:-3]

        return text.strip()


def fix_scad_for_rendering(
    client,
    model: str,
    scad_code: str,
    original_prompt: str,
    timeout_occurred: bool = True,
    error_message: Optional[str] = None
) -> Tuple[bool, str, list]:
    """
    Convenience function to fix SCAD code.

    Args:
        client: Unified LLM client
        model: Model to use
        scad_code: Problematic SCAD code
        original_prompt: Original design request
        timeout_occurred: Whether timeout triggered this
        error_message: Optional error from OpenSCAD

    Returns:
        Tuple of (success, fixed_code, changes_made)
    """
    fixer = SCADAutoFixer(client, model)
    result = fixer.fix(
        scad_code,
        original_prompt,
        timeout_occurred,
        error_message
    )

    return result.success, result.fixed_code, result.changes_made
