"""
Component Detector

Detects NopSCADlib components mentioned in user prompts.
Uses keyword matching, fuzzy matching, and semantic similarity.
"""

import re
from dataclasses import dataclass, field
from typing import List, Dict, Optional, Set, Tuple
from difflib import SequenceMatcher

from .config import (
    KB_CONFIG, CATEGORY_KEYWORDS, COMPONENT_ALIASES
)
from .indexer import ComponentInfo, load_component_index


@dataclass
class DetectedComponent:
    """A component detected in a user prompt."""
    component_id: str
    component_name: str
    module_name: str
    confidence: float           # 0.0 to 1.0
    matched_text: str           # The text that triggered the match
    match_type: str             # exact, alias, keyword, fuzzy, semantic
    start_pos: int = -1         # Position in original text
    end_pos: int = -1


@dataclass
class DetectionResult:
    """Result of component detection on a prompt."""
    original_prompt: str
    detected_components: List[DetectedComponent] = field(default_factory=list)
    detected_categories: List[str] = field(default_factory=list)
    has_kb_components: bool = False

    def get_unique_components(self) -> List[DetectedComponent]:
        """Get unique components, keeping highest confidence for duplicates."""
        seen = {}
        for comp in self.detected_components:
            if comp.component_id not in seen:
                seen[comp.component_id] = comp
            elif comp.confidence > seen[comp.component_id].confidence:
                seen[comp.component_id] = comp
        return list(seen.values())

    def get_component_ids(self) -> List[str]:
        """Get list of unique component IDs."""
        return [c.component_id for c in self.get_unique_components()]


class ComponentDetector:
    """
    Detects NopSCADlib components in natural language prompts.

    Uses multiple strategies:
    1. Exact name matching
    2. Alias matching (e.g., "9g servo" → SG90)
    3. Category keyword matching
    4. Fuzzy string matching
    5. Semantic similarity (optional, requires embeddings)
    """

    def __init__(
        self,
        components: Dict[str, ComponentInfo] = None,
        confidence_threshold: float = None
    ):
        """
        Initialize the detector.

        Args:
            components: Pre-loaded component dictionary, or will load from index
            confidence_threshold: Minimum confidence to include a match
        """
        self.components = components or {}
        self.confidence_threshold = (
            confidence_threshold or
            KB_CONFIG.detection_confidence_threshold
        )

        # Build search indices
        self._name_index: Dict[str, str] = {}      # lowercase name → component_id
        self._module_index: Dict[str, str] = {}    # module name → component_id
        self._keyword_index: Dict[str, Set[str]] = {}  # keyword → set of component_ids
        self._alias_index: Dict[str, str] = {}     # alias → component_id

        if self.components:
            self._build_indices()

    def load_components(self) -> bool:
        """Load components from the index file."""
        self.components = load_component_index()
        if self.components:
            self._build_indices()
            return True
        return False

    def _build_indices(self):
        """Build search indices from components."""
        for comp_id, comp in self.components.items():
            # Name index (lowercase)
            name_lower = comp.name.lower()
            self._name_index[name_lower] = comp_id

            # Also index with underscores replaced by spaces
            name_variants = [
                name_lower,
                name_lower.replace('_', ' '),
                name_lower.replace(' ', '_'),
                name_lower.replace('-', ' '),
                name_lower.replace(' ', '-'),
            ]
            for variant in name_variants:
                self._name_index[variant] = comp_id

            # Module name index
            module_lower = comp.module_name.lower()
            self._module_index[module_lower] = comp_id

            # Keyword index
            for keyword in comp.keywords:
                if keyword not in self._keyword_index:
                    self._keyword_index[keyword] = set()
                self._keyword_index[keyword].add(comp_id)

        # Build alias index from config
        for comp_key, aliases in COMPONENT_ALIASES.items():
            # Find matching component
            matching_ids = [
                cid for cid, comp in self.components.items()
                if comp_key.lower() in comp.module_name.lower()
            ]
            if matching_ids:
                for alias in aliases:
                    self._alias_index[alias.lower()] = matching_ids[0]

        print(f"Built indices: {len(self._name_index)} names, "
              f"{len(self._module_index)} modules, "
              f"{len(self._keyword_index)} keywords, "
              f"{len(self._alias_index)} aliases")

    def _normalize_text(self, text: str) -> str:
        """Normalize text for matching."""
        # Lowercase
        text = text.lower()
        # Normalize whitespace
        text = ' '.join(text.split())
        return text

    def _find_exact_matches(self, text: str) -> List[DetectedComponent]:
        """Find exact name/module matches in text."""
        matches = []
        text_lower = self._normalize_text(text)

        # Check module names (most specific)
        for module_name, comp_id in self._module_index.items():
            if module_name in text_lower:
                comp = self.components[comp_id]
                # Find position
                pos = text_lower.find(module_name)
                matches.append(DetectedComponent(
                    component_id=comp_id,
                    component_name=comp.name,
                    module_name=comp.module_name,
                    confidence=0.95,
                    matched_text=module_name,
                    match_type="exact_module",
                    start_pos=pos,
                    end_pos=pos + len(module_name)
                ))

        # Check component names
        for name, comp_id in self._name_index.items():
            if name in text_lower and len(name) > 3:  # Avoid very short matches
                comp = self.components[comp_id]
                pos = text_lower.find(name)
                matches.append(DetectedComponent(
                    component_id=comp_id,
                    component_name=comp.name,
                    module_name=comp.module_name,
                    confidence=0.90,
                    matched_text=name,
                    match_type="exact_name",
                    start_pos=pos,
                    end_pos=pos + len(name)
                ))

        return matches

    def _find_alias_matches(self, text: str) -> List[DetectedComponent]:
        """Find alias matches in text."""
        matches = []
        text_lower = self._normalize_text(text)

        for alias, comp_id in self._alias_index.items():
            if alias in text_lower:
                comp = self.components[comp_id]
                pos = text_lower.find(alias)
                matches.append(DetectedComponent(
                    component_id=comp_id,
                    component_name=comp.name,
                    module_name=comp.module_name,
                    confidence=0.85,
                    matched_text=alias,
                    match_type="alias",
                    start_pos=pos,
                    end_pos=pos + len(alias)
                ))

        return matches

    def _find_keyword_matches(self, text: str) -> List[DetectedComponent]:
        """Find keyword-based matches in text."""
        matches = []
        text_lower = self._normalize_text(text)
        words = set(re.findall(r'\b\w+\b', text_lower))

        # Track which components matched and with how many keywords
        component_keyword_counts: Dict[str, Tuple[int, str]] = {}

        for word in words:
            if word in self._keyword_index:
                for comp_id in self._keyword_index[word]:
                    if comp_id not in component_keyword_counts:
                        component_keyword_counts[comp_id] = (0, word)
                    count, _ = component_keyword_counts[comp_id]
                    component_keyword_counts[comp_id] = (count + 1, word)

        # Convert to DetectedComponents
        for comp_id, (count, matched_word) in component_keyword_counts.items():
            comp = self.components[comp_id]
            # Confidence based on keyword count
            base_confidence = 0.5 + (count * 0.1)
            confidence = min(base_confidence, 0.75)  # Cap at 0.75 for keyword matches

            matches.append(DetectedComponent(
                component_id=comp_id,
                component_name=comp.name,
                module_name=comp.module_name,
                confidence=confidence,
                matched_text=matched_word,
                match_type="keyword"
            ))

        return matches

    def _find_fuzzy_matches(
        self,
        text: str,
        min_ratio: float = 0.8
    ) -> List[DetectedComponent]:
        """Find fuzzy string matches for potential component names."""
        matches = []
        text_lower = self._normalize_text(text)

        # Extract potential component names (capitalized words, numbers+letters)
        potential_names = re.findall(
            r'\b[A-Z][a-z]+\d*\b|\b\w+\d+\w*\b|\b\d+\w+\b',
            text,
            re.IGNORECASE
        )

        for potential in potential_names:
            potential_lower = potential.lower()

            # Compare against module names
            for module_name, comp_id in self._module_index.items():
                ratio = SequenceMatcher(
                    None, potential_lower, module_name
                ).ratio()

                if ratio >= min_ratio:
                    comp = self.components[comp_id]
                    matches.append(DetectedComponent(
                        component_id=comp_id,
                        component_name=comp.name,
                        module_name=comp.module_name,
                        confidence=ratio * 0.8,  # Scale down fuzzy confidence
                        matched_text=potential,
                        match_type="fuzzy"
                    ))

        return matches

    def _detect_categories(self, text: str) -> List[str]:
        """Detect which component categories are mentioned."""
        categories = []
        text_lower = self._normalize_text(text)

        for category, keywords in CATEGORY_KEYWORDS.items():
            for keyword in keywords:
                if keyword in text_lower:
                    if category not in categories:
                        categories.append(category)
                    break

        return categories

    def detect(self, prompt: str) -> DetectionResult:
        """
        Detect NopSCADlib components in a user prompt.

        Args:
            prompt: User's natural language prompt

        Returns:
            DetectionResult with detected components and categories
        """
        if not self.components:
            self.load_components()

        if not self.components:
            return DetectionResult(
                original_prompt=prompt,
                detected_components=[],
                detected_categories=[],
                has_kb_components=False
            )

        all_matches = []

        # Run all detection strategies
        all_matches.extend(self._find_exact_matches(prompt))
        all_matches.extend(self._find_alias_matches(prompt))
        all_matches.extend(self._find_keyword_matches(prompt))
        all_matches.extend(self._find_fuzzy_matches(prompt))

        # Filter by confidence threshold
        filtered_matches = [
            m for m in all_matches
            if m.confidence >= self.confidence_threshold
        ]

        # Deduplicate, keeping highest confidence per component
        unique_matches = {}
        for match in filtered_matches:
            if match.component_id not in unique_matches:
                unique_matches[match.component_id] = match
            elif match.confidence > unique_matches[match.component_id].confidence:
                unique_matches[match.component_id] = match

        # Sort by confidence
        sorted_matches = sorted(
            unique_matches.values(),
            key=lambda m: m.confidence,
            reverse=True
        )

        # Limit to max components
        limited_matches = sorted_matches[:KB_CONFIG.max_components_per_query]

        # Detect categories
        categories = self._detect_categories(prompt)

        return DetectionResult(
            original_prompt=prompt,
            detected_components=limited_matches,
            detected_categories=categories,
            has_kb_components=len(limited_matches) > 0
        )

    def detect_with_context(
        self,
        prompt: str,
        previous_detections: List[str] = None
    ) -> DetectionResult:
        """
        Detect components with context from previous interactions.

        Args:
            prompt: User's current prompt
            previous_detections: Component IDs from previous turns

        Returns:
            DetectionResult
        """
        result = self.detect(prompt)

        # If we have previous context and no new detections,
        # check if the prompt references them
        if previous_detections and not result.detected_components:
            # Look for pronouns or references
            reference_patterns = [
                r'\b(it|that|the same|this)\b',
                r'\b(another|more|additional)\b',
                r'\b(like|similar to)\b'
            ]

            for pattern in reference_patterns:
                if re.search(pattern, prompt.lower()):
                    # Add previous components with lower confidence
                    for comp_id in previous_detections[:2]:  # Max 2
                        if comp_id in self.components:
                            comp = self.components[comp_id]
                            result.detected_components.append(DetectedComponent(
                                component_id=comp_id,
                                component_name=comp.name,
                                module_name=comp.module_name,
                                confidence=0.6,
                                matched_text="(context reference)",
                                match_type="context"
                            ))
                    break

        result.has_kb_components = len(result.detected_components) > 0
        return result

    def get_component_info(self, component_id: str) -> Optional[ComponentInfo]:
        """Get full component info by ID."""
        return self.components.get(component_id)

    def search_components(
        self,
        query: str,
        limit: int = 10
    ) -> List[Tuple[ComponentInfo, float]]:
        """
        Search for components matching a query.

        Returns list of (ComponentInfo, score) tuples.
        """
        result = self.detect(query)

        # Get full component info with scores
        results = []
        for detection in result.detected_components[:limit]:
            comp = self.components.get(detection.component_id)
            if comp:
                results.append((comp, detection.confidence))

        return results


# Global detector instance
_detector: Optional[ComponentDetector] = None


def get_detector() -> ComponentDetector:
    """Get or create the global detector instance."""
    global _detector
    if _detector is None:
        _detector = ComponentDetector()
        _detector.load_components()
    return _detector


def detect_components(prompt: str) -> DetectionResult:
    """
    Convenience function to detect components in a prompt.

    Args:
        prompt: User's prompt

    Returns:
        DetectionResult
    """
    detector = get_detector()
    return detector.detect(prompt)


def has_kb_components(prompt: str) -> bool:
    """Quick check if a prompt mentions any KB components."""
    result = detect_components(prompt)
    return result.has_kb_components
