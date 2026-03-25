"""
LLM-based CadQuery to OpenSCAD Translator

Uses GPT-4o to translate CadQuery Python code to OpenSCAD.
"""

import os
import re
from typing import Optional, Tuple
from dataclasses import dataclass

try:
    from openai import OpenAI
    HAS_OPENAI = True
except ImportError:
    HAS_OPENAI = False

from .config import Config


@dataclass
class TranslationResult:
    """Result of a translation attempt."""
    success: bool
    openscad_code: str
    error: Optional[str] = None
    attempts: int = 1
    model: str = "gpt-4o"


class LLMTranslator:
    """
    Translates CadQuery code to OpenSCAD using GPT-4o.

    Features:
    - Structured prompts for watertight CSG output
    - Automatic repair attempts on failure
    - Code cleaning and validation
    """

    def __init__(self, config: Optional[Config] = None, client: Optional[any] = None):
        """
        Initialize the translator.

        Args:
            config: Pipeline configuration
            client: OpenAI client (optional, will create if not provided)
        """
        if not HAS_OPENAI:
            raise ImportError("openai is required. Install with: pip install openai")

        self.config = config or Config()
        self.client = client or OpenAI()

    def translate(self, cadquery_code: str) -> TranslationResult:
        """
        Translate CadQuery code to OpenSCAD.

        Args:
            cadquery_code: CadQuery Python code string

        Returns:
            TranslationResult with OpenSCAD code or error
        """
        try:
            # First attempt
            openscad_code = self._call_llm(cadquery_code)
            openscad_code = self._clean_code(openscad_code)

            if self._validate_basic(openscad_code):
                return TranslationResult(
                    success=True,
                    openscad_code=openscad_code,
                    attempts=1,
                    model=self.config.model,
                )
            else:
                return TranslationResult(
                    success=False,
                    openscad_code=openscad_code,
                    error="Generated code failed basic validation",
                    attempts=1,
                    model=self.config.model,
                )

        except Exception as e:
            return TranslationResult(
                success=False,
                openscad_code="",
                error=str(e),
                attempts=1,
                model=self.config.model,
            )

    def repair(
        self,
        cadquery_code: str,
        openscad_code: str,
        problems: str
    ) -> TranslationResult:
        """
        Attempt to repair failed OpenSCAD code.

        Args:
            cadquery_code: Original CadQuery code
            openscad_code: Failed OpenSCAD code
            problems: Description of what went wrong

        Returns:
            TranslationResult with repaired code or error
        """
        try:
            # Build repair prompt
            repair_prompt = self.config.repair_prompt.format(
                problems=problems,
                cadquery_code=cadquery_code,
                openscad_code=openscad_code,
            )

            # Call LLM for repair
            response = self.client.chat.completions.create(
                model=self.config.model,
                messages=[
                    {"role": "system", "content": self.config.system_prompt},
                    {"role": "user", "content": repair_prompt},
                ],
                temperature=self.config.temperature,
                max_tokens=self.config.max_tokens,
            )

            repaired_code = response.choices[0].message.content
            repaired_code = self._clean_code(repaired_code)

            if self._validate_basic(repaired_code):
                return TranslationResult(
                    success=True,
                    openscad_code=repaired_code,
                    attempts=1,
                    model=self.config.model,
                )
            else:
                return TranslationResult(
                    success=False,
                    openscad_code=repaired_code,
                    error="Repaired code still fails validation",
                    attempts=1,
                    model=self.config.model,
                )

        except Exception as e:
            return TranslationResult(
                success=False,
                openscad_code=openscad_code,  # Return original
                error=f"Repair failed: {str(e)}",
                attempts=1,
                model=self.config.model,
            )

    def _call_llm(self, cadquery_code: str) -> str:
        """Make the LLM API call."""
        user_prompt = f"""Convert this CadQuery code to OpenSCAD:

```python
{cadquery_code}
```

Output only the OpenSCAD code, no explanations."""

        response = self.client.chat.completions.create(
            model=self.config.model,
            messages=[
                {"role": "system", "content": self.config.system_prompt},
                {"role": "user", "content": user_prompt},
            ],
            temperature=self.config.temperature,
            max_tokens=self.config.max_tokens,
        )

        return response.choices[0].message.content

    def _clean_code(self, code: str) -> str:
        """
        Clean the generated code.

        Removes markdown fences, explanatory text, etc.
        """
        if not code:
            return ""

        # Remove markdown code fences
        code = re.sub(r"```(?:openscad|scad)?\n?", "", code)
        code = re.sub(r"```\n?", "", code)

        # Remove common LLM artifacts
        lines = code.split("\n")
        cleaned_lines = []
        in_code = False

        for line in lines:
            stripped = line.strip().lower()

            # Skip explanatory lines
            if stripped.startswith("here is") or stripped.startswith("here's"):
                continue
            if stripped.startswith("this code") or stripped.startswith("the code"):
                continue
            if stripped.startswith("note:") or stripped.startswith("notes:"):
                continue

            # Detect start of actual code
            if not in_code:
                if any(keyword in line for keyword in [
                    "cube", "cylinder", "sphere", "translate", "rotate",
                    "union", "difference", "intersection", "module",
                    "$fn", "EPS", "eps", "//"
                ]):
                    in_code = True

            if in_code or line.strip() == "" or line.strip().startswith("//"):
                cleaned_lines.append(line)

        result = "\n".join(cleaned_lines).strip()

        # If cleaning removed everything, return original
        if not result and code.strip():
            return code.strip()

        return result

    def _validate_basic(self, code: str) -> bool:
        """
        Basic validation that the code looks like OpenSCAD.

        This is NOT a syntax check - just ensures we got code, not prose.
        """
        if not code or len(code) < 10:
            return False

        # Must contain at least one OpenSCAD keyword
        keywords = [
            "cube", "cylinder", "sphere", "polygon", "circle",
            "translate", "rotate", "scale", "mirror",
            "union", "difference", "intersection",
            "linear_extrude", "rotate_extrude",
            "module", "multmatrix"
        ]

        code_lower = code.lower()
        has_keyword = any(kw in code_lower for kw in keywords)

        # Should not be mostly prose
        words = code.split()
        if len(words) > 50:
            # Check ratio of code-like tokens
            code_tokens = sum(1 for w in words if any(c in w for c in "()[];{}="))
            if code_tokens < len(words) * 0.1:
                return False

        return has_keyword


def translate_cadquery_to_openscad(
    cadquery_code: str,
    config: Optional[Config] = None,
    client: Optional[any] = None
) -> Tuple[bool, str, str]:
    """
    Convenience function to translate CadQuery to OpenSCAD.

    Args:
        cadquery_code: CadQuery Python code
        config: Optional configuration
        client: Optional OpenAI client

    Returns:
        Tuple of (success, openscad_code, error_message)
    """
    translator = LLMTranslator(config=config, client=client)
    result = translator.translate(cadquery_code)
    return result.success, result.openscad_code, result.error or ""
