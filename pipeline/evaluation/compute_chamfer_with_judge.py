#!/usr/bin/env python3
"""
Chamfer Distance Evaluation with LLM Judge

This script:
1. Uses Gemini as an LLM judge to pick the best output for each prompt
2. Computes Chamfer distance from all methods to the winner
3. Generates a comparison table

Usage:
    python compute_chamfer_with_judge.py --results-dir ./comparison_results/20260120_XXXXXX
    python compute_chamfer_with_judge.py --results-dir ./comparison_results/20260120_XXXXXX --judge gpt-4o
"""

import os
import sys
import json
import argparse
import base64
from pathlib import Path
from typing import Dict, List, Any, Optional, Tuple
from dataclasses import dataclass, asdict
import numpy as np

# Add parent paths
sys.path.insert(0, str(Path(__file__).parent.parent))
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from dotenv import load_dotenv
load_dotenv()


# =============================================================================
# DATA STRUCTURES
# =============================================================================

@dataclass
class JudgeResult:
    """Result from LLM judge evaluation."""
    prompt_id: str
    prompt_text: str
    winner: str  # Method name that won
    winner_reason: str
    confidence: float  # 0-1
    rankings: Dict[str, int]  # Method -> rank (1=best)


@dataclass
class ChamferResult:
    """Chamfer distance result for one prompt."""
    prompt_id: str
    reference_method: str
    distances: Dict[str, float]  # Method -> Chamfer distance


@dataclass
class EvaluationSummary:
    """Full evaluation summary."""
    judge_results: List[JudgeResult]
    chamfer_results: List[ChamferResult]
    win_counts: Dict[str, int]
    avg_chamfer: Dict[str, float]


# =============================================================================
# CHAMFER DISTANCE COMPUTATION
# =============================================================================

def load_stl_as_pointcloud(stl_path: str, n_points: int = 2048) -> Optional[np.ndarray]:
    """
    Load STL file and sample point cloud from surface.

    Args:
        stl_path: Path to STL file
        n_points: Number of points to sample

    Returns:
        Numpy array of shape (n_points, 3) or None if failed
    """
    try:
        import trimesh
        mesh = trimesh.load(stl_path)

        if isinstance(mesh, trimesh.Scene):
            # If it's a scene, combine all geometries
            meshes = [g for g in mesh.geometry.values() if isinstance(g, trimesh.Trimesh)]
            if not meshes:
                return None
            mesh = trimesh.util.concatenate(meshes)

        if not isinstance(mesh, trimesh.Trimesh):
            return None

        # Sample points from surface
        points, _ = trimesh.sample.sample_surface(mesh, n_points)
        return points

    except Exception as e:
        print(f"  Warning: Failed to load {stl_path}: {e}")
        return None


def compute_chamfer_distance(pc1: np.ndarray, pc2: np.ndarray) -> float:
    """
    Compute Chamfer distance between two point clouds.

    Chamfer distance = mean(min_dist(pc1->pc2)) + mean(min_dist(pc2->pc1))

    Args:
        pc1: Point cloud 1, shape (N, 3)
        pc2: Point cloud 2, shape (M, 3)

    Returns:
        Chamfer distance (lower is better)
    """
    from scipy.spatial.distance import cdist

    # Compute pairwise distances
    dist_matrix = cdist(pc1, pc2)

    # For each point in pc1, find min distance to pc2
    min_dist_1_to_2 = np.min(dist_matrix, axis=1)

    # For each point in pc2, find min distance to pc1
    min_dist_2_to_1 = np.min(dist_matrix, axis=0)

    # Chamfer distance is sum of mean distances
    chamfer = np.mean(min_dist_1_to_2) + np.mean(min_dist_2_to_1)

    return float(chamfer)


def compute_chamfer_for_prompt(
    stl_paths: Dict[str, str],
    reference_method: str,
    n_points: int = 2048
) -> Dict[str, float]:
    """
    Compute Chamfer distances from all methods to the reference.

    Args:
        stl_paths: Dict mapping method name to STL path
        reference_method: Method to use as reference
        n_points: Number of points to sample

    Returns:
        Dict mapping method name to Chamfer distance
    """
    distances = {}

    # Load reference point cloud
    ref_path = stl_paths.get(reference_method)
    if not ref_path or not os.path.exists(ref_path):
        print(f"  Warning: Reference STL not found: {ref_path}")
        return distances

    ref_pc = load_stl_as_pointcloud(ref_path, n_points)
    if ref_pc is None:
        print(f"  Warning: Failed to load reference point cloud")
        return distances

    # Compute distance for each method
    for method, stl_path in stl_paths.items():
        if method == reference_method:
            distances[method] = 0.0
            continue

        if not stl_path or not os.path.exists(stl_path):
            distances[method] = float('inf')
            continue

        pc = load_stl_as_pointcloud(stl_path, n_points)
        if pc is None:
            distances[method] = float('inf')
            continue

        distances[method] = compute_chamfer_distance(pc, ref_pc)

    return distances


# =============================================================================
# LLM JUDGE
# =============================================================================

def encode_image_base64(image_path: str) -> str:
    """Encode image to base64 string."""
    with open(image_path, "rb") as f:
        return base64.b64encode(f.read()).decode("utf-8")


def judge_with_gemini(
    prompt_text: str,
    method_images: Dict[str, str],  # method -> image_path
    api_key: str
) -> JudgeResult:
    """
    Use Gemini to judge which output best matches the prompt.

    Args:
        prompt_text: Original CAD prompt
        method_images: Dict mapping method name to image path
        api_key: Gemini API key

    Returns:
        JudgeResult with winner and rankings
    """
    import google.generativeai as genai

    genai.configure(api_key=api_key)
    model = genai.GenerativeModel('gemini-2.0-flash')

    # Build the prompt with images
    method_labels = {
        "gpt4o_baseline": "A",
        "gpt52_baseline": "B",
        "cadence_no_rag": "C",
        "cadence_with_rag": "D"
    }

    # Prepare images
    image_parts = []
    label_to_method = {}

    for method, image_path in method_images.items():
        if image_path and os.path.exists(image_path):
            label = method_labels.get(method, method[0].upper())
            label_to_method[label] = method

            # Load image
            from PIL import Image
            img = Image.open(image_path)
            image_parts.append((label, img))

    if len(image_parts) < 2:
        # Not enough images to compare
        return JudgeResult(
            prompt_id="",
            prompt_text=prompt_text,
            winner=list(method_images.keys())[0] if method_images else "",
            winner_reason="Not enough valid images to compare",
            confidence=0.0,
            rankings={}
        )

    # Build the judge prompt
    judge_prompt = f"""You are an expert CAD model evaluator.

TASK: Evaluate which 3D CAD model render best matches the given description.

DESCRIPTION: "{prompt_text}"

I will show you {len(image_parts)} rendered images labeled {', '.join(l for l, _ in image_parts)}.

For each image, evaluate:
1. Does it match the described shape/object?
2. Are all required features present?
3. Is the geometry correct and well-formed?
4. Overall quality and accuracy

After evaluating all images, respond with EXACTLY this JSON format:
{{
    "winner": "<letter of best image>",
    "reason": "<brief explanation why this one is best>",
    "confidence": <0.0-1.0>,
    "rankings": {{"<letter>": <rank 1-{len(image_parts)}>, ...}}
}}

Where rank 1 = best, {len(image_parts)} = worst.

IMPORTANT: Output ONLY the JSON, no other text."""

    # Create content with images
    content = [judge_prompt]
    for label, img in image_parts:
        content.append(f"\nImage {label}:")
        content.append(img)

    try:
        response = model.generate_content(content)
        response_text = response.text.strip()

        # Parse JSON response
        # Clean up response if needed
        if "```json" in response_text:
            response_text = response_text.split("```json")[1].split("```")[0]
        elif "```" in response_text:
            response_text = response_text.split("```")[1].split("```")[0]

        result = json.loads(response_text)

        # Convert letter back to method name
        winner_label = result.get("winner", "A")
        winner_method = label_to_method.get(winner_label, list(method_images.keys())[0])

        # Convert rankings
        rankings = {}
        for label, rank in result.get("rankings", {}).items():
            if label in label_to_method:
                rankings[label_to_method[label]] = rank

        return JudgeResult(
            prompt_id="",
            prompt_text=prompt_text,
            winner=winner_method,
            winner_reason=result.get("reason", ""),
            confidence=float(result.get("confidence", 0.5)),
            rankings=rankings
        )

    except Exception as e:
        print(f"  Warning: Gemini judge failed: {e}")
        # Default to first available method
        return JudgeResult(
            prompt_id="",
            prompt_text=prompt_text,
            winner=list(method_images.keys())[0] if method_images else "",
            winner_reason=f"Judge error: {e}",
            confidence=0.0,
            rankings={}
        )


def judge_with_openai(
    prompt_text: str,
    method_images: Dict[str, str],
    api_key: str,
    model: str = "gpt-4o"
) -> JudgeResult:
    """
    Use OpenAI (GPT-4o) to judge which output best matches the prompt.
    """
    from openai import OpenAI

    client = OpenAI(api_key=api_key)

    method_labels = {
        "gpt4o_baseline": "A",
        "gpt52_baseline": "B",
        "cadence_no_rag": "C",
        "cadence_with_rag": "D"
    }

    # Build messages with images
    label_to_method = {}
    image_content = []

    for method, image_path in method_images.items():
        if image_path and os.path.exists(image_path):
            label = method_labels.get(method, method[0].upper())
            label_to_method[label] = method

            base64_img = encode_image_base64(image_path)
            image_content.append({
                "type": "text",
                "text": f"Image {label}:"
            })
            image_content.append({
                "type": "image_url",
                "image_url": {"url": f"data:image/png;base64,{base64_img}"}
            })

    if len(label_to_method) < 2:
        return JudgeResult(
            prompt_id="",
            prompt_text=prompt_text,
            winner=list(method_images.keys())[0] if method_images else "",
            winner_reason="Not enough valid images",
            confidence=0.0,
            rankings={}
        )

    judge_prompt = f"""You are an expert CAD model evaluator.

TASK: Evaluate which 3D CAD model render best matches the given description.

DESCRIPTION: "{prompt_text}"

Evaluate each image for:
1. Does it match the described shape/object?
2. Are all required features present?
3. Is the geometry correct and well-formed?

Respond with EXACTLY this JSON format:
{{
    "winner": "<letter of best image>",
    "reason": "<brief explanation>",
    "confidence": <0.0-1.0>,
    "rankings": {{"<letter>": <rank>, ...}}
}}

Rank 1 = best. Output ONLY JSON."""

    messages = [
        {
            "role": "user",
            "content": [{"type": "text", "text": judge_prompt}] + image_content
        }
    ]

    try:
        response = client.chat.completions.create(
            model=model,
            messages=messages,
            max_tokens=500
        )

        response_text = response.choices[0].message.content.strip()

        if "```json" in response_text:
            response_text = response_text.split("```json")[1].split("```")[0]
        elif "```" in response_text:
            response_text = response_text.split("```")[1].split("```")[0]

        result = json.loads(response_text)

        winner_label = result.get("winner", "A")
        winner_method = label_to_method.get(winner_label, list(method_images.keys())[0])

        rankings = {}
        for label, rank in result.get("rankings", {}).items():
            if label in label_to_method:
                rankings[label_to_method[label]] = rank

        return JudgeResult(
            prompt_id="",
            prompt_text=prompt_text,
            winner=winner_method,
            winner_reason=result.get("reason", ""),
            confidence=float(result.get("confidence", 0.5)),
            rankings=rankings
        )

    except Exception as e:
        print(f"  Warning: OpenAI judge failed: {e}")
        return JudgeResult(
            prompt_id="",
            prompt_text=prompt_text,
            winner=list(method_images.keys())[0] if method_images else "",
            winner_reason=f"Judge error: {e}",
            confidence=0.0,
            rankings={}
        )


# =============================================================================
# MAIN EVALUATION RUNNER
# =============================================================================

class ChamferEvaluator:
    """Main evaluator combining LLM judge and Chamfer distance."""

    def __init__(
        self,
        results_dir: str,
        judge_model: str = "gemini",
        n_points: int = 2048
    ):
        self.results_dir = Path(results_dir)
        self.judge_model = judge_model
        self.n_points = n_points

        # Load prompts and results
        self.prompts = self._load_prompts()
        self.results = self._load_results()

        # Get API keys
        self.gemini_key = os.getenv("GEMINI_API_KEY")
        self.openai_key = os.getenv("OPENAI_API_KEY")

        self.methods = ["gpt4o_baseline", "gpt52_baseline", "cadence_no_rag", "cadence_with_rag"]

    def _load_prompts(self) -> List[Dict]:
        """Load prompts from results directory."""
        prompts_path = self.results_dir / "prompts.json"
        if prompts_path.exists():
            with open(prompts_path) as f:
                return json.load(f)
        return []

    def _load_results(self) -> Dict:
        """Load generation results."""
        results_path = self.results_dir / "results.json"
        if results_path.exists():
            with open(results_path) as f:
                return json.load(f)
        return {}

    def _get_image_paths(self, prompt_id: str) -> Dict[str, str]:
        """Get image paths for all methods for a prompt."""
        paths = {}
        for method in self.methods:
            if prompt_id in self.results and method in self.results[prompt_id]:
                img_path = self.results[prompt_id][method].get("image_path")
                if img_path and os.path.exists(img_path):
                    paths[method] = img_path
        return paths

    def _get_stl_paths(self, prompt_id: str) -> Dict[str, str]:
        """Get STL paths for all methods for a prompt."""
        paths = {}
        for method in self.methods:
            if prompt_id in self.results and method in self.results[prompt_id]:
                stl_path = self.results[prompt_id][method].get("stl_path")
                if stl_path and os.path.exists(stl_path):
                    paths[method] = stl_path
        return paths

    def judge_prompt(self, prompt: Dict) -> JudgeResult:
        """Run LLM judge on a single prompt."""
        prompt_id = prompt["id"]
        prompt_text = prompt["text"]

        image_paths = self._get_image_paths(prompt_id)

        if self.judge_model == "gemini":
            if not self.gemini_key:
                raise ValueError("GEMINI_API_KEY not set")
            result = judge_with_gemini(prompt_text, image_paths, self.gemini_key)
        else:
            if not self.openai_key:
                raise ValueError("OPENAI_API_KEY not set")
            result = judge_with_openai(prompt_text, image_paths, self.openai_key, self.judge_model)

        result.prompt_id = prompt_id
        return result

    def compute_chamfer(self, prompt_id: str, reference_method: str) -> ChamferResult:
        """Compute Chamfer distances for a prompt."""
        stl_paths = self._get_stl_paths(prompt_id)
        distances = compute_chamfer_for_prompt(stl_paths, reference_method, self.n_points)

        return ChamferResult(
            prompt_id=prompt_id,
            reference_method=reference_method,
            distances=distances
        )

    def run_full_evaluation(self) -> EvaluationSummary:
        """Run complete evaluation: judge + Chamfer distance."""
        print(f"\n{'='*70}")
        print("Chamfer Distance Evaluation with LLM Judge")
        print(f"{'='*70}")
        print(f"Results directory: {self.results_dir}")
        print(f"Judge model: {self.judge_model}")
        print(f"Prompts: {len(self.prompts)}")
        print(f"{'='*70}\n")

        judge_results = []
        chamfer_results = []
        win_counts = {m: 0 for m in self.methods}
        chamfer_sums = {m: [] for m in self.methods}

        for i, prompt in enumerate(self.prompts):
            prompt_id = prompt["id"]
            print(f"[{i+1}/{len(self.prompts)}] {prompt_id}: {prompt['text'][:40]}...")

            # Step 1: LLM Judge
            print(f"  Judging with {self.judge_model}...")
            judge_result = self.judge_prompt(prompt)
            judge_results.append(judge_result)

            winner = judge_result.winner
            if winner in win_counts:
                win_counts[winner] += 1

            print(f"  Winner: {winner} ({judge_result.winner_reason[:50]}...)")

            # Step 2: Chamfer Distance
            print(f"  Computing Chamfer distances...")
            chamfer_result = self.compute_chamfer(prompt_id, winner)
            chamfer_results.append(chamfer_result)

            # Track distances
            for method, dist in chamfer_result.distances.items():
                if dist != float('inf'):
                    chamfer_sums[method].append(dist)

            # Print distances
            for method in self.methods:
                dist = chamfer_result.distances.get(method, float('inf'))
                marker = " (ref)" if method == winner else ""
                if dist == float('inf'):
                    print(f"    {method}: N/A{marker}")
                else:
                    print(f"    {method}: {dist:.4f}{marker}")
            print()

        # Compute averages
        avg_chamfer = {}
        for method in self.methods:
            if chamfer_sums[method]:
                avg_chamfer[method] = np.mean(chamfer_sums[method])
            else:
                avg_chamfer[method] = float('inf')

        summary = EvaluationSummary(
            judge_results=judge_results,
            chamfer_results=chamfer_results,
            win_counts=win_counts,
            avg_chamfer=avg_chamfer
        )

        # Save results
        self._save_results(summary)

        # Print summary
        self._print_summary(summary)

        return summary

    def _save_results(self, summary: EvaluationSummary):
        """Save evaluation results to JSON."""
        output = {
            "judge_results": [asdict(r) for r in summary.judge_results],
            "chamfer_results": [asdict(r) for r in summary.chamfer_results],
            "win_counts": summary.win_counts,
            "avg_chamfer": summary.avg_chamfer
        }

        output_path = self.results_dir / "chamfer_evaluation.json"
        with open(output_path, "w") as f:
            json.dump(output, f, indent=2)

        print(f"\nResults saved to: {output_path}")

        # Also generate markdown table
        self._generate_markdown_table(summary)

    def _generate_markdown_table(self, summary: EvaluationSummary):
        """Generate markdown table for paper."""
        lines = []
        lines.append("# Chamfer Distance Evaluation Results\n")
        lines.append("## LLM Judge Results\n")
        lines.append("| Prompt | Winner | Confidence | Reason |")
        lines.append("|--------|--------|------------|--------|")

        for jr in summary.judge_results:
            reason = jr.winner_reason[:40] + "..." if len(jr.winner_reason) > 40 else jr.winner_reason
            lines.append(f"| {jr.prompt_id} | {jr.winner} | {jr.confidence:.2f} | {reason} |")

        lines.append("\n## Win Counts\n")
        lines.append("| Method | Wins |")
        lines.append("|--------|------|")
        for method, count in sorted(summary.win_counts.items(), key=lambda x: -x[1]):
            lines.append(f"| {method} | {count} |")

        lines.append("\n## Chamfer Distances\n")
        lines.append("| Prompt | Reference | " + " | ".join(self.methods) + " |")
        lines.append("|--------|-----------|" + "|".join(["---"] * len(self.methods)) + "|")

        for cr in summary.chamfer_results:
            row = f"| {cr.prompt_id} | {cr.reference_method} |"
            for method in self.methods:
                dist = cr.distances.get(method, float('inf'))
                if dist == 0:
                    row += " **0.0** |"
                elif dist == float('inf'):
                    row += " N/A |"
                else:
                    row += f" {dist:.4f} |"
            lines.append(row)

        lines.append("\n## Average Chamfer Distance\n")
        lines.append("| Method | Avg Chamfer |")
        lines.append("|--------|-------------|")
        for method in self.methods:
            avg = summary.avg_chamfer.get(method, float('inf'))
            if avg == float('inf'):
                lines.append(f"| {method} | N/A |")
            else:
                lines.append(f"| {method} | {avg:.4f} |")

        md_path = self.results_dir / "chamfer_evaluation.md"
        with open(md_path, "w") as f:
            f.write("\n".join(lines))

        print(f"Markdown table saved to: {md_path}")

    def _print_summary(self, summary: EvaluationSummary):
        """Print evaluation summary."""
        print(f"\n{'='*70}")
        print("SUMMARY")
        print(f"{'='*70}")

        print("\nWin Counts (LLM Judge):")
        for method, count in sorted(summary.win_counts.items(), key=lambda x: -x[1]):
            pct = count / len(self.prompts) * 100 if self.prompts else 0
            print(f"  {method}: {count}/{len(self.prompts)} ({pct:.1f}%)")

        print("\nAverage Chamfer Distance (lower = better):")
        for method in self.methods:
            avg = summary.avg_chamfer.get(method, float('inf'))
            if avg == float('inf'):
                print(f"  {method}: N/A")
            else:
                print(f"  {method}: {avg:.4f}")

        print(f"\n{'='*70}")


# =============================================================================
# CLI
# =============================================================================

def find_latest_results_dir(base_dir: str = "./comparison_results") -> Optional[str]:
    """Find the most recent results directory."""
    base_path = Path(base_dir)
    if not base_path.exists():
        return None

    # Find all timestamp directories
    dirs = [d for d in base_path.iterdir() if d.is_dir() and d.name[0].isdigit()]
    if not dirs:
        return None

    # Sort by name (timestamp format YYYYMMDD_HHMMSS)
    dirs.sort(key=lambda x: x.name, reverse=True)
    return str(dirs[0])


def main():
    parser = argparse.ArgumentParser(
        description="Chamfer Distance Evaluation with LLM Judge",
        formatter_class=argparse.RawDescriptionHelpFormatter
    )

    parser.add_argument("--results-dir", type=str, default=None,
                        help="Path to comparison results directory (auto-detects latest if not specified)")
    parser.add_argument("--judge", type=str, default="gemini",
                        choices=["gemini", "gpt-4o"],
                        help="LLM model to use as judge")
    parser.add_argument("--n-points", type=int, default=2048,
                        help="Number of points to sample for Chamfer distance")

    args = parser.parse_args()

    # Auto-detect results directory if not specified
    results_dir = args.results_dir
    if not results_dir:
        results_dir = find_latest_results_dir()
        if results_dir:
            print(f"Auto-detected results directory: {results_dir}")
        else:
            print("ERROR: No results directory found in ./comparison_results/")
            print("Run 'python run_qualitative_comparison.py' first, or specify --results-dir")
            sys.exit(1)

    # Verify results directory exists
    if not os.path.exists(results_dir):
        print(f"ERROR: Results directory not found: {results_dir}")
        sys.exit(1)

    # Check API keys
    if args.judge == "gemini" and not os.getenv("GEMINI_API_KEY"):
        print("ERROR: GEMINI_API_KEY not set")
        print("Get a free key at: https://aistudio.google.com/")
        sys.exit(1)

    if args.judge == "gpt-4o" and not os.getenv("OPENAI_API_KEY"):
        print("ERROR: OPENAI_API_KEY not set")
        sys.exit(1)

    # Run evaluation
    evaluator = ChamferEvaluator(
        results_dir=results_dir,
        judge_model=args.judge,
        n_points=args.n_points
    )

    evaluator.run_full_evaluation()


if __name__ == "__main__":
    main()
