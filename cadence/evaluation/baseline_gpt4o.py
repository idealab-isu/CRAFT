"""
GPT-4o Direct Baseline

Direct OpenSCAD generation using GPT-4o without the CADence pipeline.
This serves as the baseline for comparison.
"""

import os
import re
import time
import json
from dataclasses import dataclass, asdict
from typing import Optional, Tuple
from pathlib import Path

from openai import OpenAI
from dotenv import load_dotenv

load_dotenv()


# System prompt for direct OpenSCAD generation
BASELINE_SYSTEM_PROMPT = """You are an OpenSCAD code generator. Generate valid, executable OpenSCAD code based on user descriptions.

Requirements:
1. Output ONLY valid OpenSCAD code - no explanations, no markdown, no comments about the design
2. The code must be syntactically correct and render without errors
3. Use appropriate primitives: cube(), cylinder(), sphere(), etc.
4. Use boolean operations: union(), difference(), intersection()
5. Use transformations: translate(), rotate(), scale()
6. Include reasonable default dimensions if not specified
7. Make the design centered at origin when appropriate

Output format: Raw OpenSCAD code only, starting immediately with code (no ```openscad or other markers)."""


BASELINE_USER_TEMPLATE = """Generate OpenSCAD code for: {prompt}

Output only the raw OpenSCAD code, nothing else."""


@dataclass
class BaselineResult:
    """Result from baseline generation."""
    prompt_id: str
    prompt_text: str

    # Generation
    code: Optional[str] = None
    generation_time: float = 0.0

    # Validation
    syntax_valid: bool = False
    render_success: bool = False
    has_geometry: bool = False

    # Paths
    scad_path: Optional[str] = None
    image_path: Optional[str] = None

    # Errors
    error: Optional[str] = None

    def to_dict(self):
        return asdict(self)


class GPT4oBaseline:
    """
    Direct GPT-4o baseline for OpenSCAD generation.

    No intermediate planning, no validation loop, no repair.
    Just direct prompt → code generation.
    """

    def __init__(
        self,
        client: Optional[OpenAI] = None,
        model: str = "gpt-4o",
        output_dir: str = "./evaluation/baseline_outputs",
        temperature: float = 0.2
    ):
        self.client = client or OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
        self.model = model
        self.output_dir = Path(output_dir)
        self.temperature = temperature

        # Create output directories
        self.output_dir.mkdir(parents=True, exist_ok=True)
        (self.output_dir / "scad").mkdir(exist_ok=True)
        (self.output_dir / "images").mkdir(exist_ok=True)

    def generate(self, prompt_id: str, prompt_text: str) -> BaselineResult:
        """
        Generate OpenSCAD code for a prompt.

        Args:
            prompt_id: Unique identifier for this prompt
            prompt_text: Natural language description

        Returns:
            BaselineResult with generated code and validation results
        """
        result = BaselineResult(
            prompt_id=prompt_id,
            prompt_text=prompt_text
        )

        start_time = time.time()

        try:
            # Generate code
            response = self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {"role": "system", "content": BASELINE_SYSTEM_PROMPT},
                    {"role": "user", "content": BASELINE_USER_TEMPLATE.format(prompt=prompt_text)}
                ],
                temperature=self.temperature,
                max_tokens=2000
            )

            raw_code = response.choices[0].message.content.strip()
            result.code = self._clean_code(raw_code)
            result.generation_time = time.time() - start_time

            # Save and validate
            result = self._save_and_validate(result)

        except Exception as e:
            result.error = str(e)
            result.generation_time = time.time() - start_time

        return result

    def _clean_code(self, raw_code: str) -> str:
        """Clean up generated code (remove markdown, etc.)."""
        # Remove markdown code blocks
        if "```" in raw_code:
            # Extract code from markdown block
            pattern = r"```(?:openscad|scad)?\s*\n?(.*?)```"
            match = re.search(pattern, raw_code, re.DOTALL)
            if match:
                raw_code = match.group(1)

        # Remove leading/trailing whitespace
        raw_code = raw_code.strip()

        return raw_code

    def _save_and_validate(self, result: BaselineResult) -> BaselineResult:
        """Save code to file and validate."""
        if not result.code:
            return result

        # Save SCAD file
        scad_path = self.output_dir / "scad" / f"{result.prompt_id}.scad"
        with open(scad_path, "w") as f:
            f.write(result.code)
        result.scad_path = str(scad_path)

        # Check syntax
        result.syntax_valid = self._check_syntax(result.code, str(scad_path))

        if result.syntax_valid:
            # Try to render
            image_path = self.output_dir / "images" / f"{result.prompt_id}.png"
            result.render_success = self._render(str(scad_path), str(image_path))

            if result.render_success:
                result.image_path = str(image_path)
                result.has_geometry = self._check_geometry(str(image_path))

        return result

    def _check_syntax(self, code: str, scad_path: str) -> bool:
        """Check if OpenSCAD code has valid syntax."""
        import subprocess

        try:
            # Use OpenSCAD to check syntax (--export with no output checks parsing)
            result = subprocess.run(
                ["openscad", "--export-format", "echo", "-o", "/dev/null", scad_path],
                capture_output=True,
                text=True,
                timeout=30
            )

            # Check for syntax errors in stderr
            stderr = result.stderr.lower()
            has_error = "error" in stderr or "parse error" in stderr

            return not has_error

        except Exception:
            # If OpenSCAD not available, do basic check
            return self._basic_syntax_check(code)

    def _basic_syntax_check(self, code: str) -> bool:
        """Basic syntax validation without OpenSCAD."""
        # Check for balanced braces/parentheses
        if code.count('(') != code.count(')'):
            return False
        if code.count('{') != code.count('}'):
            return False
        if code.count('[') != code.count(']'):
            return False

        # Check for basic OpenSCAD constructs
        has_construct = any(kw in code.lower() for kw in [
            'cube', 'cylinder', 'sphere', 'union', 'difference',
            'translate', 'rotate', 'scale', 'linear_extrude', 'polygon'
        ])

        return has_construct

    def _render(self, scad_path: str, image_path: str) -> bool:
        """Render SCAD file to image."""
        import subprocess

        try:
            result = subprocess.run(
                [
                    "openscad",
                    "-o", image_path,
                    "--imgsize=800,600",
                    "--preview",
                    "--autocenter",
                    "--viewall",
                    scad_path
                ],
                capture_output=True,
                text=True,
                timeout=60
            )

            return (
                result.returncode == 0 and
                os.path.exists(image_path) and
                os.path.getsize(image_path) > 0
            )

        except Exception:
            return False

    def _check_geometry(self, image_path: str) -> bool:
        """Check if rendered image has visible geometry (not empty)."""
        try:
            from PIL import Image
            import numpy as np

            img = Image.open(image_path).convert('L')
            arr = np.array(img)

            # Check for non-background pixels
            # Background is typically uniform, geometry adds variation
            std = np.std(arr)

            # If std > 10, there's likely some geometry
            return bool(std > 10)

        except Exception:
            # If we can't check, assume it's OK if render succeeded
            return True

    def run_batch(self, prompts: list) -> list:
        """
        Run baseline on a batch of prompts.

        Args:
            prompts: List of dicts with 'id' and 'text' keys

        Returns:
            List of BaselineResult objects
        """
        results = []

        for prompt in prompts:
            print(f"[Baseline] Processing: {prompt['id']}")
            result = self.generate(prompt['id'], prompt['text'])
            results.append(result)

            # Brief pause to avoid rate limits
            time.sleep(0.5)

        # Save results
        self._save_results(results)

        return results

    def _save_results(self, results: list):
        """Save results to JSON file."""
        results_path = self.output_dir / "baseline_results.json"
        with open(results_path, "w") as f:
            json.dump([r.to_dict() for r in results], f, indent=2)


def run_baseline(
    prompts: list,
    output_dir: str = "./evaluation/baseline_outputs",
    model: str = "gpt-4o"
) -> list:
    """
    Convenience function to run baseline evaluation.

    Args:
        prompts: List of prompt dicts with 'id' and 'text'
        output_dir: Output directory
        model: Model to use

    Returns:
        List of BaselineResult objects
    """
    baseline = GPT4oBaseline(output_dir=output_dir, model=model)
    return baseline.run_batch(prompts)
