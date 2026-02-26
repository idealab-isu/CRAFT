"""
CADence Vision Analyzer

This module analyzes multi-view images (6 orthographic + 4 isometric) to:
- Generate a best caption describing the object
- Generate 3 alternative captions for robustness
- Extract identified geometric features

The output feeds into the Text Reasoner to create a unified Design Brief.

Supports both GPT-4o (Chat Completions API) and GPT-5.2 (Responses API).
"""

import base64
import io
import json
import os
import time
from typing import Any, Dict, List, Optional, Tuple
from dataclasses import dataclass, asdict
from PIL import Image


# =============================================================================
# MODEL CONFIGURATION
# =============================================================================

# Models that require Responses API for vision (input_image format)
RESPONSES_API_VISION_MODELS = {"gpt-5.2"}

# Models that use max_completion_tokens instead of max_tokens
NEW_API_MODELS = {"gpt-5.1", "gpt-5.2", "o1", "o1-mini", "o1-preview", "o3", "o3-mini"}

# Retry configuration
MAX_RETRIES = 3
RETRY_DELAY_BASE = 2  # Base delay in seconds for exponential backoff


@dataclass
class VisionAnalysis:
    """Results from vision analysis."""
    best_caption: str
    alternatives: List[str]
    identified_features: Dict[str, Any]
    view_names: List[str]

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)


@dataclass
class SingleImageAnalysis:
    """Results from single image concept understanding (GPT-5.2 only)."""
    object_identified: str
    best_caption: str
    alternatives: List[str]
    geometric_breakdown: Dict[str, Any]
    proportions: Dict[str, Any]
    distinctive_features: List[str]
    cad_hints: str

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)


# =============================================================================
# PROMPTS
# =============================================================================

VISION_CAPTION_PROMPT = """Analyze all these views of a 3D object.

You are provided with multiple rendered views:
- 6 orthographic views: front, back, left, right, top, bottom
- 4 isometric views: iso1, iso2, iso3, iso4

Your task: Generate comprehensive descriptions of this object.

OUTPUT FORMAT (strict JSON):
{
    "best": "The single most comprehensive and accurate description (2-3 sentences). Include: primary object type, key structural features, functional purpose if evident.",
    "alternatives": [
        "Alternative description 1 - different terminology or emphasis",
        "Alternative description 2 - focus on geometry vs. function",
        "Alternative description 3 - manufacturing/engineering perspective"
    ],
    "features": {
        "primary_shape": "main geometric form (e.g., cylindrical, rectangular, complex)",
        "primitives": ["list of identifiable primitive shapes"],
        "features": ["holes", "slots", "protrusions", "handles", etc.],
        "symmetry": "type of symmetry if any",
        "estimated_complexity": "simple|medium|complex"
    }
}

GUIDELINES:
- Be specific and technical
- Describe what you SEE, not what you assume
- Note structural relationships between parts
- Identify the primary shape and how features attach to it
- Each alternative should provide genuinely different perspective

Respond ONLY with valid JSON."""


VISION_GEOMETRIC_PROMPT = """Analyze these views and describe the geometric structure.

Focus on:
1. What primitives could construct this? (boxes, cylinders, spheres, etc.)
2. What boolean operations are evident? (holes = difference, assembled parts = union)
3. What are the approximate proportions?

Output JSON:
{
    "suggested_primitives": [
        {"type": "cylinder", "role": "main body", "relative_size": "large"},
        {"type": "box", "role": "handle attachment", "relative_size": "small"}
    ],
    "suggested_operations": [
        {"type": "difference", "purpose": "create hollow interior"},
        {"type": "union", "purpose": "attach handle"}
    ],
    "proportions": {
        "aspect_ratio": "roughly equal|tall|wide|deep",
        "main_to_feature_ratio": "features are X% of main body"
    }
}"""


# =============================================================================
# SINGLE IMAGE CONCEPT UNDERSTANDING PROMPT (GPT-5.2 ONLY)
# =============================================================================

SINGLE_IMAGE_CONCEPT_PROMPT = """You are an expert at understanding real-world objects from photographs and translating them into 3D CAD model descriptions.

Analyze this single image carefully. Your goal is to understand:
1. WHAT is the object (e.g., ice cream cone, coffee mug, toy car)
2. Its STRUCTURE - how it's composed of geometric primitives
3. Its PROPORTIONS - relative sizes of parts
4. Its DISTINCTIVE FEATURES - what makes it recognizable

Think step by step:
- First identify the object category and purpose
- Break it down into geometric components (cones, cylinders, spheres, boxes, etc.)
- Note any curves, tapers, or organic shapes
- Identify key proportions (e.g., "cone is 3x taller than the scoop")
- Note textures or surface details that could be approximated geometrically

OUTPUT FORMAT (strict JSON):
{
    "object_identified": "Human-readable name of the object (e.g., 'ice cream cone with single scoop')",
    "best": "Comprehensive CAD-focused description (2-4 sentences). Describe the object in terms that would help a CAD system recreate it. Include: primary shape, component breakdown, proportions, key features.",
    "alternatives": [
        "Alternative description 1 - emphasizing different structural aspects",
        "Alternative description 2 - emphasizing geometric primitives",
        "Alternative description 3 - emphasizing proportions and dimensions"
    ],
    "geometric_breakdown": {
        "primary_form": "Main geometric classification (e.g., 'tapered cone topped with sphere')",
        "components": [
            {"part": "part_name", "primitive": "geometric primitive", "relative_size": "large/medium/small", "position": "where relative to main body"}
        ],
        "suggested_primitives": ["cone", "sphere", "cylinder", etc.],
        "suggested_operations": ["union", "difference", etc.],
        "symmetry": "radial|bilateral|asymmetric|none",
        "estimated_complexity": "simple|medium|complex"
    },
    "proportions": {
        "overall_aspect": "tall|wide|cubic|flat",
        "key_ratios": ["ratio description 1", "ratio description 2"]
    },
    "distinctive_features": ["feature1", "feature2", "..."],
    "cad_hints": "Specific suggestions for CAD implementation (e.g., 'Use tapered cylinder for cone, smooth sphere union at top')"
}

IMPORTANT:
- Focus on GEOMETRIC interpretation, not artistic details
- Think about how this would be built in a 3D modeling program
- Organic shapes should be approximated with appropriate primitives
- Be specific about proportions using ratios where possible
- PREFER SIMPLE GEOMETRY that will render reliably:
  - Use basic primitives (sphere, cylinder, cone, cube) over complex patterns
  - Avoid suggesting surface textures or patterns in cad_hints - these often cause rendering failures
  - For textures like waffle patterns, grids, or surface details: suggest "optional visual detail, not structural"
  - The goal is a RECOGNIZABLE shape, not photorealistic detail

Respond ONLY with valid JSON."""


# =============================================================================
# IMAGE PROCESSING UTILITIES
# =============================================================================

def encode_image_as_data_url(
    image_path: str,
    max_side: int = 768,
    quality: int = 80
) -> str:
    """
    Encode an image as a base64 data URL, with optional resizing.
    
    Args:
        image_path: Path to the image file
        max_side: Maximum dimension (width or height)
        quality: JPEG quality (1-100)
        
    Returns:
        Data URL string (data:image/jpeg;base64,...)
    """
    img = Image.open(image_path).convert("RGB")
    w, h = img.size
    
    # Resize if needed
    scale = min(1.0, max_side / max(w, h))
    if scale < 1.0:
        new_size = (int(w * scale), int(h * scale))
        img = img.resize(new_size, Image.LANCZOS)
    
    # Encode to JPEG
    buffer = io.BytesIO()
    img.save(buffer, format="JPEG", quality=quality, optimize=True)
    b64 = base64.b64encode(buffer.getvalue()).decode("utf-8")
    
    return f"data:image/jpeg;base64,{b64}"


def encode_pil_image(
    img: Image.Image,
    max_side: int = 768,
    quality: int = 80
) -> str:
    """
    Encode a PIL Image as a base64 data URL.
    """
    img = img.convert("RGB")
    w, h = img.size
    
    scale = min(1.0, max_side / max(w, h))
    if scale < 1.0:
        new_size = (int(w * scale), int(h * scale))
        img = img.resize(new_size, Image.LANCZOS)
    
    buffer = io.BytesIO()
    img.save(buffer, format="JPEG", quality=quality, optimize=True)
    b64 = base64.b64encode(buffer.getvalue()).decode("utf-8")
    
    return f"data:image/jpeg;base64,{b64}"


# =============================================================================
# DEFAULT VIEW NAMES
# =============================================================================

DEFAULT_VIEW_NAMES = [
    "front", "back", "left", "right", "top", "bottom",
    "iso1", "iso2", "iso3", "iso4"
]

ORTHO_VIEW_NAMES = ["front", "back", "left", "right", "top", "bottom"]
ISO_VIEW_NAMES = ["iso1", "iso2", "iso3", "iso4"]


# =============================================================================
# VISION ANALYZER CLASS
# =============================================================================

class VisionAnalyzer:
    """
    Analyzes multi-view images to generate captions and feature descriptions.

    Supports both GPT-4o (Chat Completions API) and GPT-5.2 (Responses API).
    """

    def __init__(self, client, model: str = "gpt-4o"):
        """
        Initialize the vision analyzer.

        Args:
            client: Unified LLM client instance (supports both APIs)
            model: Vision-capable model to use
        """
        self.client = client
        self.model = model

    def _get_token_param(self, max_tokens: int) -> Dict[str, int]:
        """Get the correct token limit parameter based on model."""
        if self.model in NEW_API_MODELS:
            return {"max_completion_tokens": max_tokens}
        return {"max_tokens": max_tokens}

    def _call_vision_api(
        self,
        system_prompt: str,
        user_prompt: str,
        image_paths: List[str],
        view_names: List[str],
        max_tokens: int = 2000,
        temperature: float = 0.3,
        json_response: bool = True
    ) -> str:
        """
        Call the appropriate vision API based on model.

        - GPT-5.2: Uses Responses API with input_image format
        - GPT-4o/GPT-5.1: Uses Chat Completions API with image_url format

        Includes retry logic with exponential backoff.
        """
        last_error = None

        for attempt in range(MAX_RETRIES + 1):
            try:
                if self.model in RESPONSES_API_VISION_MODELS:
                    return self._call_responses_api(
                        system_prompt, user_prompt, image_paths, view_names,
                        max_tokens, temperature, json_response
                    )
                else:
                    return self._call_chat_completions_api(
                        system_prompt, user_prompt, image_paths, view_names,
                        max_tokens, temperature, json_response
                    )
            except Exception as e:
                last_error = e
                if attempt < MAX_RETRIES:
                    delay = RETRY_DELAY_BASE ** attempt
                    print(f"[Vision] API call failed (attempt {attempt + 1}), retrying in {delay}s: {e}")
                    time.sleep(delay)
                else:
                    raise last_error

        raise last_error

    def _call_responses_api(
        self,
        system_prompt: str,
        user_prompt: str,
        image_paths: List[str],
        view_names: List[str],
        max_tokens: int,
        temperature: float,
        json_response: bool
    ) -> str:
        """
        Call OpenAI Responses API for GPT-5.2 vision.

        Uses input_image format instead of image_url.
        """
        content_parts = []

        # Add system context as part of user message (Responses API)
        if system_prompt:
            content_parts.append({
                "type": "input_text",
                "text": f"CONTEXT: {system_prompt}\n\n"
            })

        # Add user prompt
        content_parts.append({
            "type": "input_text",
            "text": user_prompt
        })

        # Add images with labels
        for i, path in enumerate(image_paths):
            label = view_names[i] if i < len(view_names) else f"view_{i+1}"

            # Add label
            content_parts.append({
                "type": "input_text",
                "text": f"\n--- {label} ---"
            })

            # Add image using input_image format
            data_url = encode_image_as_data_url(path)
            content_parts.append({
                "type": "input_image",
                "image_url": data_url
            })

        # Build kwargs for Responses API
        kwargs = {}
        if json_response:
            kwargs["text"] = {"format": {"type": "json_object"}}

        response = self.client.responses.create(
            model=self.model,
            input=[{"role": "user", "content": content_parts}],
            temperature=temperature,
            max_output_tokens=max_tokens,
            **kwargs
        )

        return response.output_text

    def _call_chat_completions_api(
        self,
        system_prompt: str,
        user_prompt: str,
        image_paths: List[str],
        view_names: List[str],
        max_tokens: int,
        temperature: float,
        json_response: bool
    ) -> str:
        """
        Call OpenAI Chat Completions API for GPT-4o/GPT-5.1 vision.

        Uses image_url format.
        """
        content = self._build_image_content(image_paths, view_names)

        messages = []
        if system_prompt:
            messages.append({
                "role": "system",
                "content": system_prompt
            })

        messages.append({
            "role": "user",
            "content": [
                {"type": "text", "text": user_prompt}
            ] + content
        })

        kwargs = {
            "model": self.model,
            "messages": messages,
            "temperature": temperature,
            **self._get_token_param(max_tokens)
        }

        if json_response:
            kwargs["response_format"] = {"type": "json_object"}

        response = self.client.chat.completions.create(**kwargs)
        return response.choices[0].message.content

    def analyze(
        self,
        image_paths: List[str],
        view_names: Optional[List[str]] = None
    ) -> VisionAnalysis:
        """
        Analyze multiple views of an object.

        Args:
            image_paths: List of paths to view images
            view_names: Optional list of view names (defaults to standard 10-view setup)

        Returns:
            VisionAnalysis with captions and features
        """
        if not image_paths:
            raise ValueError("No images provided")

        # Use default view names if not provided
        if view_names is None:
            view_names = DEFAULT_VIEW_NAMES[:len(image_paths)]

        try:
            # Get captions using the appropriate API
            result_text = self._call_vision_api(
                system_prompt="You are an expert at analyzing 3D CAD objects from multiple views.",
                user_prompt=VISION_CAPTION_PROMPT,
                image_paths=image_paths,
                view_names=view_names,
                max_tokens=2000,
                temperature=0.3,
                json_response=True
            )

            # Parse JSON response with robust extraction
            data = self._extract_json(result_text)

            return VisionAnalysis(
                best_caption=data.get("best", "3D CAD object"),
                alternatives=data.get("alternatives", [])[:3],
                identified_features=data.get("features", {}),
                view_names=view_names
            )

        except Exception as e:
            # Fallback
            print(f"[Vision] Analysis failed: {e}")
            return VisionAnalysis(
                best_caption=f"3D object (vision analysis failed: {str(e)[:50]})",
                alternatives=[
                    "A mechanical component",
                    "An engineered part",
                    "A manufactured object"
                ],
                identified_features={"error": str(e)},
                view_names=view_names
            )

    def _extract_json(self, text: str) -> Dict[str, Any]:
        """
        Robustly extract JSON from text, handling markdown code blocks.
        """
        import re

        # Try direct parse first
        try:
            return json.loads(text)
        except json.JSONDecodeError:
            pass

        # Try to find JSON in code blocks
        json_block_pattern = r'```(?:json)?\s*([\s\S]*?)```'
        matches = re.findall(json_block_pattern, text)

        for match in matches:
            try:
                return json.loads(match.strip())
            except json.JSONDecodeError:
                continue

        # Try to find JSON object pattern
        json_obj_pattern = r'\{[\s\S]*\}'
        obj_matches = re.findall(json_obj_pattern, text)

        for match in obj_matches:
            try:
                return json.loads(match)
            except json.JSONDecodeError:
                continue

        # Return empty dict if nothing works
        print(f"[Vision] Failed to extract JSON from: {text[:200]}...")
        return {}
    
    def _build_image_content(
        self,
        image_paths: List[str],
        view_names: List[str]
    ) -> List[Dict[str, Any]]:
        """Build the content list with labeled images."""
        content = []
        
        for i, path in enumerate(image_paths):
            label = view_names[i] if i < len(view_names) else f"view_{i+1}"
            
            # Add label
            content.append({
                "type": "text",
                "text": f"--- {label} ---"
            })
            
            # Add image
            data_url = encode_image_as_data_url(path)
            content.append({
                "type": "image_url",
                "image_url": {"url": data_url, "detail": "high"}
            })
        
        return content
    
    def get_geometric_analysis(
        self,
        image_paths: List[str],
        view_names: Optional[List[str]] = None
    ) -> Dict[str, Any]:
        """
        Get detailed geometric analysis suggesting primitives and operations.

        This is a separate call focused on construction strategy.
        Uses the unified API calling method for proper model support.
        """
        if view_names is None:
            view_names = DEFAULT_VIEW_NAMES[:len(image_paths)]

        try:
            result_text = self._call_vision_api(
                system_prompt="You are a CAD expert analyzing objects for reconstruction.",
                user_prompt=VISION_GEOMETRIC_PROMPT,
                image_paths=image_paths,
                view_names=view_names,
                max_tokens=2000,
                temperature=0.2,
                json_response=True
            )

            return self._extract_json(result_text)

        except Exception as e:
            print(f"[Vision] Geometric analysis failed: {e}")
            return {"error": str(e)}


# =============================================================================
# SINGLE IMAGE ANALYZER (GPT-5.2 ONLY)
# =============================================================================

# Fixed model for single image - always use the best reasoning model
SINGLE_IMAGE_MODEL = "gpt-5.2"


class SingleImageAnalyzer:
    """
    Analyzes a single concept image to understand the object and generate CAD descriptions.

    ALWAYS uses GPT-5.2 (best reasoning model) for deep understanding.
    Designed for real-world photographs of objects (ice cream, coffee mug, etc.)
    that need to be translated into CAD model descriptions.
    """

    def __init__(self, client):
        """
        Initialize the single image analyzer.

        Args:
            client: Unified LLM client instance (supports Responses API)
        """
        self.client = client
        self.model = SINGLE_IMAGE_MODEL  # Always GPT-5.2

    def analyze(self, image_path: str) -> SingleImageAnalysis:
        """
        Analyze a single image to understand the object for CAD generation.

        Uses GPT-5.2's reasoning capabilities to:
        1. Identify what the object is
        2. Break it down into geometric primitives
        3. Understand proportions and structure
        4. Provide CAD-focused descriptions

        Args:
            image_path: Path to the image file

        Returns:
            SingleImageAnalysis with comprehensive CAD-focused description
        """
        if not image_path:
            raise ValueError("No image provided")

        print(f"[SingleImage] Analyzing image with {self.model} (reasoning model)")

        try:
            # Call GPT-5.2 Responses API with the single image
            result_text = self._call_responses_api(image_path)

            # Parse JSON response
            data = self._extract_json(result_text)

            # Extract geometric breakdown with defaults
            geo = data.get("geometric_breakdown", {})
            props = data.get("proportions", {})

            return SingleImageAnalysis(
                object_identified=data.get("object_identified", "Unknown object"),
                best_caption=data.get("best", "3D object from image"),
                alternatives=data.get("alternatives", [])[:3],
                geometric_breakdown={
                    "primary_form": geo.get("primary_form", "complex shape"),
                    "components": geo.get("components", []),
                    "suggested_primitives": geo.get("suggested_primitives", []),
                    "suggested_operations": geo.get("suggested_operations", []),
                    "symmetry": geo.get("symmetry", "unknown"),
                    "estimated_complexity": geo.get("estimated_complexity", "medium")
                },
                proportions={
                    "overall_aspect": props.get("overall_aspect", "unknown"),
                    "key_ratios": props.get("key_ratios", [])
                },
                distinctive_features=data.get("distinctive_features", []),
                cad_hints=data.get("cad_hints", "")
            )

        except Exception as e:
            print(f"[SingleImage] Analysis failed: {e}")
            return SingleImageAnalysis(
                object_identified=f"Unknown (analysis failed: {str(e)[:30]})",
                best_caption="3D object from single image (vision analysis failed)",
                alternatives=[
                    "A physical object",
                    "An item to be 3D modeled",
                    "A real-world object"
                ],
                geometric_breakdown={
                    "primary_form": "unknown",
                    "components": [],
                    "suggested_primitives": ["box", "cylinder", "sphere"],
                    "suggested_operations": ["union"],
                    "symmetry": "unknown",
                    "estimated_complexity": "medium"
                },
                proportions={
                    "overall_aspect": "unknown",
                    "key_ratios": []
                },
                distinctive_features=[],
                cad_hints="Analyze the image manually to determine structure"
            )

    def _call_responses_api(self, image_path: str) -> str:
        """
        Call OpenAI Responses API with GPT-5.2 for single image analysis.

        Uses input_image format for the Responses API.
        """
        content_parts = []

        # Add the prompt
        content_parts.append({
            "type": "input_text",
            "text": SINGLE_IMAGE_CONCEPT_PROMPT
        })

        # Add the single image
        content_parts.append({
            "type": "input_text",
            "text": "\n--- Object Image ---"
        })

        data_url = encode_image_as_data_url(image_path, max_side=1024, quality=90)
        content_parts.append({
            "type": "input_image",
            "image_url": data_url
        })

        # Build request for Responses API (GPT-5.2)
        last_error = None
        for attempt in range(MAX_RETRIES + 1):
            try:
                response = self.client.responses.create(
                    model=self.model,
                    input=[{"role": "user", "content": content_parts}],
                    temperature=0.3,  # Low temp for consistent analysis
                    max_output_tokens=3000,  # More tokens for detailed breakdown
                    text={"format": {"type": "json_object"}}
                )
                return response.output_text

            except Exception as e:
                last_error = e
                if attempt < MAX_RETRIES:
                    delay = RETRY_DELAY_BASE ** attempt
                    print(f"[SingleImage] API call failed (attempt {attempt + 1}), retrying in {delay}s: {e}")
                    time.sleep(delay)
                else:
                    raise last_error

        raise last_error

    def _extract_json(self, text: str) -> Dict[str, Any]:
        """Extract JSON from response text with robust handling."""
        import re

        # Try direct parse first
        try:
            return json.loads(text)
        except json.JSONDecodeError:
            pass

        # Try to find JSON in code blocks
        json_block_pattern = r'```(?:json)?\s*([\s\S]*?)```'
        matches = re.findall(json_block_pattern, text)

        for match in matches:
            try:
                return json.loads(match.strip())
            except json.JSONDecodeError:
                continue

        # Try to find JSON object pattern
        json_obj_pattern = r'\{[\s\S]*\}'
        obj_matches = re.findall(json_obj_pattern, text)

        for match in obj_matches:
            try:
                return json.loads(match)
            except json.JSONDecodeError:
                continue

        print(f"[SingleImage] Failed to extract JSON from: {text[:200]}...")
        return {}


def analyze_single_image(client, image_path: str) -> SingleImageAnalysis:
    """
    Convenience function to analyze a single concept image.

    Always uses GPT-5.2 for best reasoning capabilities.

    Args:
        client: Unified LLM client
        image_path: Path to the image file

    Returns:
        SingleImageAnalysis instance
    """
    analyzer = SingleImageAnalyzer(client)
    return analyzer.analyze(image_path)


def single_image_to_design_brief(client, image_path: str):
    """
    Convert single image analysis to a DesignBrief.

    This function:
    1. Analyzes the single image with GPT-5.2 to understand the object
    2. Creates an enhanced prompt from the analysis
    3. Feeds it to the TextReasoner to create a DesignBrief
    4. Augments with geometric insights from the image analysis

    Args:
        client: Unified LLM client
        image_path: Path to the image file

    Returns:
        Tuple of (DesignBrief, SingleImageAnalysis)
    """
    from .reasoner import TextReasoner

    # Step 1: Analyze image with GPT-5.2
    analyzer = SingleImageAnalyzer(client)
    image_result = analyzer.analyze(image_path)

    # Step 2: Build enhanced prompt from analysis
    enhanced_prompt = _build_enhanced_prompt(image_result)

    # Step 3: Use TextReasoner to create DesignBrief
    # Use gpt-4o for reasoner (fast), image analysis already done with gpt-5.2
    reasoner = TextReasoner(client, "gpt-4o", use_kb=False)  # No KB for concept images
    brief = reasoner.analyze(enhanced_prompt)

    # Step 4: Augment with image-specific info
    brief.source = "single_image"
    brief.original_input = json.dumps({
        "object_identified": image_result.object_identified,
        "best_caption": image_result.best_caption,
        "alternatives": image_result.alternatives,
        "geometric_breakdown": image_result.geometric_breakdown,
        "cad_hints": image_result.cad_hints
    })

    return brief, image_result


def _build_enhanced_prompt(analysis: SingleImageAnalysis) -> str:
    """
    Build an enhanced prompt from SingleImageAnalysis for the TextReasoner.

    Combines the best caption with geometric insights.
    """
    # Start with the identified object and best caption
    parts = [
        f"Create a 3D CAD model of: {analysis.object_identified}.",
        "",
        analysis.best_caption
    ]

    # Add geometric guidance if available
    geo = analysis.geometric_breakdown
    if geo.get("primary_form"):
        parts.append(f"\nPrimary form: {geo['primary_form']}")

    if geo.get("components"):
        components_desc = []
        for c in geo["components"][:5]:  # Limit to 5 components
            comp_str = f"- {c.get('part', 'part')}: {c.get('primitive', 'shape')}"
            if c.get('position'):
                comp_str += f" ({c['position']})"
            components_desc.append(comp_str)
        if components_desc:
            parts.append("\nKey components:")
            parts.extend(components_desc)

    if geo.get("suggested_primitives"):
        parts.append(f"\nSuggested primitives: {', '.join(geo['suggested_primitives'][:6])}")

    # Add proportions
    props = analysis.proportions
    if props.get("key_ratios"):
        parts.append(f"\nProportions: {'; '.join(props['key_ratios'][:3])}")

    # Add CAD hints
    if analysis.cad_hints:
        parts.append(f"\nCAD implementation hint: {analysis.cad_hints}")

    return "\n".join(parts)


# =============================================================================
# INTEGRATION WITH TEXT REASONER
# =============================================================================

def vision_to_design_brief(
    client,
    image_paths: List[str],
    view_names: Optional[List[str]] = None,
    model: str = "gpt-4o"
):
    """
    Convert vision analysis to a DesignBrief.
    
    This function:
    1. Analyzes the images to get captions
    2. Feeds the best caption to the TextReasoner
    3. Returns a unified DesignBrief
    
    Args:
        client: OpenAI client
        image_paths: List of image file paths
        view_names: Optional view names
        model: Model to use
        
    Returns:
        DesignBrief instance
    """
    from .reasoner import TextReasoner, DesignBrief
    
    # Step 1: Vision analysis
    analyzer = VisionAnalyzer(client, model)
    vision_result = analyzer.analyze(image_paths, view_names)
    
    # Step 2: Use best caption with text reasoner
    reasoner = TextReasoner(client, model)
    brief = reasoner.analyze(vision_result.best_caption)
    
    # Step 3: Augment with vision-specific info
    brief.source = "vision"
    brief.original_input = json.dumps({
        "best_caption": vision_result.best_caption,
        "alternatives": vision_result.alternatives,
        "features": vision_result.identified_features,
        "image_count": len(image_paths)
    })
    
    return brief, vision_result


# =============================================================================
# CONVENIENCE FUNCTIONS
# =============================================================================

def analyze_views(
    client,
    image_paths: List[str],
    view_names: Optional[List[str]] = None,
    model: str = "gpt-4o"
) -> VisionAnalysis:
    """
    Convenience function to analyze views.
    
    Args:
        client: OpenAI client
        image_paths: List of image paths
        view_names: Optional view names
        model: Model to use
        
    Returns:
        VisionAnalysis instance
    """
    analyzer = VisionAnalyzer(client, model)
    return analyzer.analyze(image_paths, view_names)
