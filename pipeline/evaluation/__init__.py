"""
CADence Evaluation Module

Provides comparison framework for CADence vs baselines.
"""

from .test_prompts import TEST_PROMPTS, get_prompts_by_category, get_all_prompts
from .baseline_gpt4o import GPT4oBaseline, BaselineResult
from .comparison import ComparisonRunner, ComparisonResult, run_full_comparison

__all__ = [
    "TEST_PROMPTS",
    "get_prompts_by_category",
    "get_all_prompts",
    "GPT4oBaseline",
    "BaselineResult",
    "ComparisonRunner",
    "ComparisonResult",
    "run_full_comparison",
]
