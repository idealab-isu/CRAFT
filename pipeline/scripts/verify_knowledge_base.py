#!/usr/bin/env python3
"""
Verify the NopSCADlib knowledge base is usable by CRAFT.

Checks:
  - component_index.json exists and is non-empty
  - NopSCADlib checkout exists
  - ChromaDB directory populated and document count matches index (optional)
  - OPENAI_API_KEY present (required for semantic vector retrieval)
  - Sample detect_components + retrieve_components calls succeed

Usage (from repo root or pipeline/):
    cd pipeline && python scripts/verify_knowledge_base.py
"""

from __future__ import annotations

import json
import os
import sys
from pathlib import Path

PIPELINE = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(PIPELINE))

try:
    from dotenv import load_dotenv
    for env_path in (PIPELINE / ".env", PIPELINE.parent / ".env"):
        if env_path.exists():
            load_dotenv(env_path)
            break
except ImportError:
    pass

from kb import (  # noqa: E402
    detect_components,
    retrieve_components,
    get_kb_status,
    is_kb_ready,
)


def main() -> int:
    print("=" * 60)
    print("CRAFT Knowledge Base — verification")
    print("=" * 60)

    status = get_kb_status()
    for key in sorted(status.keys()):
        if key == "retriever_stats":
            print(f"  {key}:")
            for sk, sv in status[key].items():
                print(f"      {sk}: {sv}")
        else:
            print(f"  {key}: {status[key]}")

    if not is_kb_ready():
        print("\nFAIL: KB index missing or empty. Run: python scripts/build_knowledge_base.py")
        return 1

    if status.get("retriever_stats", {}).get("chroma_error"):
        print(
            "\nERROR: ChromaDB on disk is unreadable (often chromadb upgrade or "
            "corruption). Keyword fallback still works; vector RAG does not.\n"
            "  Fix (from pipeline/, with OPENAI_API_KEY set):\n"
            "    rm -rf kb_data/chroma_db\n"
            "    python -c \"from kb import load_component_index; "
            "from kb.retriever import KnowledgeRetriever; "
            "c=load_component_index(); r=KnowledgeRetriever(); r.build_index(c)\"\n"
            "  Or full rebuild: python scripts/build_knowledge_base.py "
            "(answer 'n' at index prompt if json already exists, vectors still run).\n"
            "  Pin chromadb to match the version that created the DB if you share "
            "the store across machines (see pipeline/requirements.txt)."
        )

    if not status.get("semantic_search_ready"):
        print(
            "\nWARN: Semantic search not fully ready "
            "(need OPENAI_API_KEY + working Chroma + indexed vectors). "
            "Retriever will fall back to keyword overlap."
        )

    bench = PIPELINE.parent / "Experimentation" / "GroundTruth" / "benchmark_ground_truth_v2.json"
    samples = [
        "A ball bearing: 8 mm bore, 22 mm outer diameter, 7 mm width.",
        "A seven-segment LED display module: 12.7 mm x 19 mm body.",
    ]
    if bench.exists():
        data = json.loads(bench.read_text())
        for c in data.get("components", [])[:2]:
            samples.append(c.get("prompt", ""))

    print("\n--- smoke tests (detect + retrieve) ---")
    for text in samples:
        if not text.strip():
            continue
        dr = detect_components(text)
        ids = dr.get_component_ids()[:3]
        rc = retrieve_components(text, top_k=2)
        top = [r.component.name for r in rc.results[:2]]
        print(f"  prompt: {text[:72]}...")
        print(f"    detect: {ids}")
        print(f"    retrieve: {top}")

    print("\nOK — KB verification finished.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
