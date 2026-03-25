"""
CAD-Coder: CadQuery to OpenSCAD Translation Pipeline

This module provides tools for converting the GenCAD-Code dataset
(163k CadQuery samples) to OpenSCAD format with verification.
"""

from .config import Config
from .loader import GenCADLoader
from .llm_translator import LLMTranslator
from .verifier import Verifier
from .pipeline import TranslationPipeline

__all__ = [
    "Config",
    "GenCADLoader",
    "LLMTranslator",
    "Verifier",
    "TranslationPipeline",
]
