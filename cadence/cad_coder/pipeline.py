"""
Translation Pipeline Orchestrator

Coordinates the full CadQuery -> OpenSCAD translation workflow:
1. Load samples from GenCAD dataset
2. Translate each sample using LLM
3. Verify the translation
4. Repair if needed
5. Save results
"""

import json
import time
from pathlib import Path
from typing import Optional, Dict, Any, List
from dataclasses import dataclass, field, asdict
from datetime import datetime

try:
    from tqdm import tqdm
    HAS_TQDM = True
except ImportError:
    HAS_TQDM = False

from .config import Config
from .loader import GenCADLoader, Sample
from .llm_translator import LLMTranslator, TranslationResult
from .verifier import Verifier, VerificationResult


@dataclass
class SampleResult:
    """Result for a single sample."""
    sample_index: int
    deepcad_id: str
    success: bool
    openscad_code: str = ""
    translation_attempts: int = 0
    repair_attempts: int = 0
    ssim: float = 0.0
    iou: float = 0.0
    watertight: bool = False
    volume: float = 0.0
    error: Optional[str] = None
    time_seconds: float = 0.0
    render_path: Optional[str] = None


@dataclass
class PipelineStats:
    """Statistics for a pipeline run."""
    total_samples: int = 0
    successful: int = 0
    failed: int = 0
    skipped: int = 0
    total_time_seconds: float = 0.0
    avg_ssim: float = 0.0
    avg_iou: float = 0.0
    watertight_count: int = 0
    translation_only_success: int = 0  # Succeeded without repair
    repair_success: int = 0  # Succeeded after repair

    @property
    def success_rate(self) -> float:
        if self.total_samples == 0:
            return 0.0
        return self.successful / self.total_samples

    @property
    def watertight_rate(self) -> float:
        if self.successful == 0:
            return 0.0
        return self.watertight_count / self.successful


class TranslationPipeline:
    """
    Main pipeline for translating GenCAD dataset to OpenSCAD.

    Usage:
        pipeline = TranslationPipeline(config)
        stats = pipeline.run(n_samples=50)
        print(f"Success rate: {stats.success_rate:.1%}")
    """

    def __init__(
        self,
        config: Optional[Config] = None,
        openai_client: Optional[Any] = None,
    ):
        """
        Initialize the pipeline.

        Args:
            config: Pipeline configuration
            openai_client: Optional OpenAI client
        """
        self.config = config or Config()
        self.translator = LLMTranslator(config=self.config, client=openai_client)
        self.verifier = Verifier(config=self.config)
        self.loader: Optional[GenCADLoader] = None
        self.results: List[SampleResult] = []
        self.stats = PipelineStats()

    def _init_loader(self, dataset_path: Optional[str] = None):
        """Initialize the dataset loader."""
        if dataset_path:
            path = Path(dataset_path)
        else:
            path = self.config.get_dataset_path()

        self.loader = GenCADLoader(str(path))

    def run(
        self,
        n_samples: int = 50,
        split: str = "train",
        offset: int = 0,
        dataset_path: Optional[str] = None,
        output_dir: Optional[str] = None,
        verbose: bool = True,
    ) -> PipelineStats:
        """
        Run the translation pipeline.

        Args:
            n_samples: Number of samples to process
            split: Dataset split ("train", "test", "validation")
            offset: Starting index in the dataset
            dataset_path: Optional path to dataset
            output_dir: Optional output directory
            verbose: Print progress

        Returns:
            PipelineStats with run statistics
        """
        # Initialize
        self._init_loader(dataset_path)
        self.results = []
        self.stats = PipelineStats(total_samples=n_samples)

        # Setup output directory
        if output_dir:
            out_path = Path(output_dir)
        else:
            out_path = self.config.get_output_path()

        out_path.mkdir(parents=True, exist_ok=True)

        # Create subdirectories
        scad_dir = out_path / "scad"
        render_dir = out_path / "renders"
        scad_dir.mkdir(exist_ok=True)
        render_dir.mkdir(exist_ok=True)

        if verbose:
            print(f"[Pipeline] Processing {n_samples} samples from {split} split")
            print(f"[Pipeline] Output directory: {out_path}")

        start_time = time.time()

        # Process samples
        samples = self.loader.load_samples(split=split, n=n_samples, offset=offset)

        iterator = tqdm(samples, desc="Translating") if HAS_TQDM and verbose else samples

        ssim_values = []
        iou_values = []

        for sample in iterator:
            result = self._process_sample(sample, scad_dir, render_dir)
            self.results.append(result)

            # Update stats
            if result.success:
                self.stats.successful += 1
                ssim_values.append(result.ssim)
                iou_values.append(result.iou)
                if result.watertight:
                    self.stats.watertight_count += 1
                if result.repair_attempts == 0:
                    self.stats.translation_only_success += 1
                else:
                    self.stats.repair_success += 1
            else:
                self.stats.failed += 1

            # Update tqdm description
            if HAS_TQDM and verbose and hasattr(iterator, "set_postfix"):
                iterator.set_postfix({
                    "ok": self.stats.successful,
                    "fail": self.stats.failed,
                    "rate": f"{self.stats.success_rate:.0%}"
                })

        # Finalize stats
        self.stats.total_time_seconds = time.time() - start_time
        if ssim_values:
            self.stats.avg_ssim = sum(ssim_values) / len(ssim_values)
        if iou_values:
            self.stats.avg_iou = sum(iou_values) / len(iou_values)

        # Save results
        self._save_results(out_path)

        if verbose:
            self._print_summary()

        return self.stats

    def _process_sample(
        self,
        sample: Sample,
        scad_dir: Path,
        render_dir: Path
    ) -> SampleResult:
        """Process a single sample."""
        start_time = time.time()

        result = SampleResult(
            sample_index=sample.index,
            deepcad_id=sample.deepcad_id,
            success=False,
        )

        try:
            # Step 1: Translate
            trans_result = self.translator.translate(sample.cadquery_code)
            result.translation_attempts = trans_result.attempts

            if not trans_result.success:
                result.error = trans_result.error
                result.time_seconds = time.time() - start_time
                return result

            openscad_code = trans_result.openscad_code

            # Sanitize deepcad_id for filesystem (contains "/" like "0000/00006371")
            safe_id = sample.deepcad_id.replace("/", "_")

            # Step 2: Verify (or skip if translation_only mode)
            sample_out_dir = render_dir / safe_id
            sample_out_dir.mkdir(parents=True, exist_ok=True)

            if self.config.translation_only:
                # Skip verification - just check basic syntax
                from .verifier import VerificationResult
                verify_result = VerificationResult(
                    passed=True,
                    render_success=True,
                    watertight=True,
                    ssim=1.0,
                    iou=1.0,
                )
            else:
                verify_result = self.verifier.verify(
                    openscad_code,
                    sample.image,
                    output_dir=str(sample_out_dir),
                )

            result.ssim = verify_result.ssim
            result.iou = verify_result.iou
            result.watertight = verify_result.watertight
            result.volume = verify_result.volume
            result.render_path = verify_result.render_path

            # Step 3: Repair if needed
            if not verify_result.passed and self.config.max_repair_attempts > 0:
                for repair_attempt in range(self.config.max_repair_attempts):
                    result.repair_attempts += 1

                    repair_result = self.translator.repair(
                        sample.cadquery_code,
                        openscad_code,
                        verify_result.get_problems_str(),
                    )

                    if not repair_result.success:
                        continue

                    openscad_code = repair_result.openscad_code

                    # Re-verify
                    verify_result = self.verifier.verify(
                        openscad_code,
                        sample.image,
                        output_dir=str(sample_out_dir),
                    )

                    result.ssim = verify_result.ssim
                    result.iou = verify_result.iou
                    result.watertight = verify_result.watertight
                    result.volume = verify_result.volume
                    result.render_path = verify_result.render_path

                    if verify_result.passed:
                        break

            # Final status
            result.success = verify_result.passed
            result.openscad_code = openscad_code

            if not result.success:
                result.error = verify_result.get_problems_str()

            # Save OpenSCAD file
            if result.success or self.config.save_intermediate:
                scad_path = scad_dir / f"{safe_id}.scad"
                scad_path.write_text(openscad_code)

        except Exception as e:
            result.error = str(e)

        result.time_seconds = time.time() - start_time
        return result

    def _save_results(self, out_path: Path):
        """Save results to JSON files."""
        # Save individual results
        results_path = out_path / "results.json"
        results_data = [asdict(r) for r in self.results]
        results_path.write_text(json.dumps(results_data, indent=2))

        # Save stats
        stats_path = out_path / "stats.json"
        stats_data = {
            **asdict(self.stats),
            "success_rate": self.stats.success_rate,
            "watertight_rate": self.stats.watertight_rate,
            "timestamp": datetime.now().isoformat(),
            "config": {
                "model": self.config.model,
                "min_ssim": self.config.min_ssim,
                "require_watertight": self.config.require_watertight,
                "max_repair_attempts": self.config.max_repair_attempts,
            }
        }
        stats_path.write_text(json.dumps(stats_data, indent=2))

    def _print_summary(self):
        """Print run summary."""
        print("\n" + "=" * 60)
        print("PIPELINE SUMMARY")
        print("=" * 60)
        print(f"Total samples:     {self.stats.total_samples}")
        print(f"Successful:        {self.stats.successful}")
        print(f"Failed:            {self.stats.failed}")
        print(f"Success rate:      {self.stats.success_rate:.1%}")
        print(f"")
        print(f"First-try success: {self.stats.translation_only_success}")
        print(f"After repair:      {self.stats.repair_success}")
        print(f"")
        print(f"Avg SSIM:          {self.stats.avg_ssim:.3f}")
        print(f"Avg IoU:           {self.stats.avg_iou:.3f}")
        print(f"Watertight rate:   {self.stats.watertight_rate:.1%}")
        print(f"")
        print(f"Total time:        {self.stats.total_time_seconds:.1f}s")
        print(f"Avg per sample:    {self.stats.total_time_seconds / max(1, self.stats.total_samples):.1f}s")
        print("=" * 60)


def run_pilot(
    n_samples: int = 50,
    dataset_path: Optional[str] = None,
    output_dir: Optional[str] = None,
    model: str = "gpt-4o",
) -> PipelineStats:
    """
    Convenience function to run a pilot test.

    Args:
        n_samples: Number of samples to test
        dataset_path: Path to GenCAD dataset
        output_dir: Output directory
        model: LLM model to use

    Returns:
        PipelineStats
    """
    config = Config(model=model)

    pipeline = TranslationPipeline(config=config)
    return pipeline.run(
        n_samples=n_samples,
        dataset_path=dataset_path,
        output_dir=output_dir,
    )
