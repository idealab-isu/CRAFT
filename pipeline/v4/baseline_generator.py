"""
CRAFT v4 — Stage 0: Baseline SCAD generator.

Single GPT-5.2 call producing parametric OpenSCAD. The system prompt is
designed to recover the parametric editability story without needing a JSON
IR:

    1. All dimensions declared as named parameters at the top of the file.
    2. Parameter declarations are annotated with `// [min:max]` ranges so
       OpenSCAD's customizer interface auto-generates sliders.
    3. Geometry MUST reference parameters, not literals. Only fixed
       constants (e.g. M3 hole = 3.2 mm) may appear inline.

Output is the raw SCAD string. Saving + rendering happens downstream.
"""

from __future__ import annotations

import os
import re
import time
from dataclasses import dataclass
from typing import Optional

from openai import OpenAI


SYSTEM_PROMPT_PARAMETRIC = """You are a senior OpenSCAD engineer. Generate a complete, parametric OpenSCAD program for the user's request.

HARD REQUIREMENTS — every output MUST satisfy ALL of these:

1. PARAMETERIC HEADER. The file starts with a block of named parameters that
   covers every dimension and count needed. Each parameter line follows:
       name = value;        // [min:max]   short comment
   Use sensible defaults and reasonable ranges so the OpenSCAD customizer
   produces useful sliders.

2. NO MAGIC NUMBERS IN GEOMETRY. After the parameter block, geometry must
   reference parameters, not raw literals. The only literals allowed in
   geometry are well-known fixed constants (e.g. M3 clearance = 3.2 mm,
   default $fn). If a number is dimensional, lift it into the parameter
   block.

3. CENTERED AT ORIGIN unless the prompt clearly implies otherwise.

4. SYMMETRY THROUGH FORMULAS. Use translate(...)/rotate(...) values that are
   computed from the parameters (e.g. translate([w/2 + side_w/2 - eps, 0, 0])),
   never arbitrary integers.

5. CONNECTIVITY. The model must be one connected solid unless the prompt
   explicitly asks for separate parts. Use a small overlap (eps = 0.5 mm)
   when joining shapes to avoid coplanar faces.

6. SCOPE DISCIPLINE. Output ONLY what the user asked for. Do NOT add display
   stands, mounting bases, demonstration scenes, PCBs, or annotations
   unless explicitly requested.

7. FACET QUALITY. Set $fn = 64 globally at the top, after the parameter
   block, unless the prompt asks for a coarser/finer model.

8. OUTPUT FORMAT. Output ONLY raw OpenSCAD code. No markdown fences, no
   commentary, no JSON. The first non-whitespace character must begin the
   parameter block.
"""


USER_PROMPT_TEMPLATE = """Generate a parametric OpenSCAD program for this request:

{prompt}

Remember: parameter block first with `// [min:max]` ranges; geometry references parameters; one connected solid; scope-disciplined output; no markdown.
"""


@dataclass
class BaselineOutput:
    """Result of a single baseline generation call."""
    code: str
    raw_response: str
    elapsed_s: float
    model: str
    error: Optional[str] = None

    @property
    def ok(self) -> bool:
        return bool(self.code) and self.error is None


class BaselineGenerator:
    """GPT-5.2 (or any chat model) single-call SCAD generator."""

    def __init__(
        self,
        client: Optional[OpenAI] = None,
        model: str = "gpt-5.2",
        temperature: float = 0.2,
        max_tokens: int = 4000,
    ):
        self.client = client or OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
        self.model = model
        self.temperature = temperature
        self.max_tokens = max_tokens

    def generate(self, prompt: str, kb_hint: Optional[str] = None) -> BaselineOutput:
        """Generate parametric SCAD for one prompt.

        Args:
            prompt: Natural-language description.
            kb_hint: Optional context block from the KB reference layer. Passed
                purely as informational text — never as a hard constraint.
        """
        user_msg = USER_PROMPT_TEMPLATE.format(prompt=prompt)
        if kb_hint:
            user_msg = (
                user_msg
                + "\n\nReference (informational only — use as a hint, never required):\n"
                + kb_hint
            )

        start = time.time()
        try:
            kwargs = {
                "model": self.model,
                "messages": [
                    {"role": "system", "content": SYSTEM_PROMPT_PARAMETRIC},
                    {"role": "user", "content": user_msg},
                ],
                "temperature": self.temperature,
            }

            # GPT-5.x uses max_completion_tokens, GPT-4o uses max_tokens
            if self.model in {"gpt-5.1", "gpt-5.2", "o1", "o1-mini", "o3", "o3-mini"}:
                kwargs["max_completion_tokens"] = self.max_tokens
            else:
                kwargs["max_tokens"] = self.max_tokens

            response = self.client.chat.completions.create(**kwargs)
            raw = (response.choices[0].message.content or "").strip()
            code = self._strip_markdown(raw)

            return BaselineOutput(
                code=code,
                raw_response=raw,
                elapsed_s=time.time() - start,
                model=self.model,
            )
        except Exception as e:
            return BaselineOutput(
                code="",
                raw_response="",
                elapsed_s=time.time() - start,
                model=self.model,
                error=str(e),
            )

    @staticmethod
    def _strip_markdown(text: str) -> str:
        """Strip ```openscad fences if the model included them despite instructions."""
        if "```" not in text:
            return text.strip()
        m = re.search(r"```(?:openscad|scad)?\s*\n?(.*?)```", text, re.DOTALL)
        return m.group(1).strip() if m else text.strip()
