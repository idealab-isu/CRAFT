"""
Progress tracking and streaming for the CRAFT pipeline.

Tracks execution through each stage and emits progress updates
with ETA estimates for frontend progress bar.
"""

import time
import json
from enum import Enum
from typing import Callable, Optional, Dict, Any
from dataclasses import dataclass, asdict


class PipelineStage(Enum):
    """Pipeline execution stages with estimated durations (seconds)."""
    UNDERSTANDING = ("understanding", 15, "Analyzing design requirements...")
    PLANNING = ("planning", 20, "Creating CAD plan...")
    COMPILATION = ("compilation", 10, "Generating OpenSCAD code...")
    RENDERING = ("rendering", 30, "Rendering 3D preview...")
    VLM_CORRECTION = ("vlm_correction", 45, "Visual quality check...")
    COMPONENT_VERIFY = ("component_verify", 30, "Verifying components...")
    EXPORT = ("export", 10, "Exporting STL...")
    COMPLETE = ("complete", 0, "Complete")

    def __init__(self, stage_id: str, duration: float, message: str):
        self.stage_id = stage_id
        self.duration = duration
        self.message = message


@dataclass
class ProgressUpdate:
    """Single progress update event."""
    stage: str                  # Current pipeline stage
    progress: float            # 0.0 to 1.0
    message: str               # Human-readable status
    eta_seconds: int           # Estimated time remaining
    details: Optional[Dict[str, Any]] = None  # Stage-specific details


class ProgressTracker:
    """
    Tracks pipeline progress and emits updates to a callback.

    Usage:
        tracker = ProgressTracker(
            stages=[UNDERSTANDING, PLANNING, COMPILATION, RENDERING, VLM_CORRECTION],
            on_progress=lambda update: print(update)
        )

        with tracker.stage(PipelineStage.PLANNING):
            # ... planning code ...
            tracker.update_current_stage(0.5, "Optimizing plan...")
    """

    def __init__(
        self,
        stages: list[PipelineStage],
        on_progress: Optional[Callable[[ProgressUpdate], None]] = None
    ):
        """
        Initialize tracker.

        Args:
            stages: Pipeline stages in order
            on_progress: Callback for progress updates (SSE handler)
        """
        self.stages = stages
        self.on_progress = on_progress
        self.start_time = time.time()
        self.current_stage_idx = 0
        self.current_stage_progress = 0.0  # 0.0 to 1.0 within stage
        self.stage_start_time = self.start_time

        # Calculate total estimated duration
        self.total_duration = sum(stage.duration for stage in stages)

        # Emit initial update
        self._emit_update()

    def update_current_stage(
        self,
        progress: float,
        message: Optional[str] = None,
        details: Optional[Dict[str, Any]] = None
    ):
        """
        Update progress within the current stage.

        Args:
            progress: 0.0 to 1.0 within current stage
            message: Optional custom message
            details: Optional details dict (e.g., {"parts_verified": 3, "total": 5})
        """
        self.current_stage_progress = min(1.0, max(0.0, progress))
        if message is None:
            message = self.stages[self.current_stage_idx].message

        self._emit_update(message, details)

    def move_to_stage(self, stage_idx: int):
        """Move to the next stage."""
        if stage_idx >= len(self.stages):
            stage_idx = len(self.stages) - 1

        self.current_stage_idx = stage_idx
        self.current_stage_progress = 0.0
        self.stage_start_time = time.time()
        self._emit_update()

    def next_stage(self):
        """Move to the next stage."""
        self.move_to_stage(self.current_stage_idx + 1)

    def _emit_update(
        self,
        message: Optional[str] = None,
        details: Optional[Dict[str, Any]] = None
    ):
        """Emit progress update."""
        if not self.on_progress:
            return

        stage = self.stages[self.current_stage_idx]

        # Calculate overall progress (0.0 to 1.0)
        completed_duration = sum(s.duration for s in self.stages[:self.current_stage_idx])
        current_stage_duration = stage.duration
        current_stage_contribution = (
            self.current_stage_progress * current_stage_duration
            if current_stage_duration > 0 else 0
        )
        overall_progress = (completed_duration + current_stage_contribution) / self.total_duration
        overall_progress = min(0.99, max(0.0, overall_progress))  # Cap at 99% until done

        # Estimate time remaining
        elapsed = time.time() - self.start_time
        if overall_progress > 0.01:
            estimated_total = elapsed / overall_progress
            eta_seconds = int(estimated_total - elapsed)
        else:
            eta_seconds = int(self.total_duration)

        update = ProgressUpdate(
            stage=stage.stage_id,
            progress=overall_progress,
            message=message or stage.message,
            eta_seconds=max(0, eta_seconds),
            details=details
        )

        self.on_progress(update)

    def context_manager(self, stage: PipelineStage):
        """Context manager for stage execution."""
        class StageContext:
            def __init__(ctx_self, tracker):
                ctx_self.tracker = tracker
                ctx_self.stage = stage

            def __enter__(ctx_self):
                stage_idx = [s for s in ctx_self.tracker.stages].index(ctx_self.stage)
                ctx_self.tracker.move_to_stage(stage_idx)
                return ctx_self.tracker

            def __exit__(ctx_self, exc_type, exc_val, exc_tb):
                if exc_type is None:
                    ctx_self.tracker.current_stage_progress = 1.0
                    ctx_self.tracker._emit_update()

        return StageContext(self)


def create_sse_progress_handler(send_event_func: Callable) -> Callable:
    """
    Create an SSE progress handler for streaming updates to frontend.

    Args:
        send_event_func: Function that sends SSE event (takes dict)

    Returns:
        Callback function suitable for ProgressTracker.on_progress
    """
    def handler(update: ProgressUpdate):
        event_data = {
            "stage": update.stage,
            "progress": round(update.progress, 3),
            "message": update.message,
            "eta": update.eta_seconds,
        }
        if update.details:
            event_data["details"] = update.details

        send_event_func(event_data)

    return handler
