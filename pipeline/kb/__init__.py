"""
NopSCADlib Knowledge Base Module

Provides RAG (Retrieval Augmented Generation) capabilities for accurate
reproduction of real-world mechanical and electronic components.

Main components:
- indexer: Parse and index NopSCADlib repository
- renderer: Render reference images for components
- detector: Detect component mentions in prompts
- retriever: Retrieve components from vector store
- verifier: Verify generated output against references
"""

from .config import (
    KB_CONFIG,
    KBConfig,
    VerificationThresholds,
    DetectionStrategiesConfig,
    get_config,
    update_config,
    NOPSCADLIB_DIR,
    CHROMA_DB_DIR,
    REFERENCE_IMAGES_DIR,
    COMPONENT_INDEX_PATH,
    DOCUMENTATION_PATH,
    KB_DATA_DIR,
    CATEGORY_KEYWORDS,
    COMPONENT_ALIASES
)

from .indexer import (
    ComponentInfo,
    ComponentParameter,
    NopSCADlibIndexer,
    index_nopscadlib,
    load_component_index
)

from .renderer import (
    ComponentRenderer,
    CameraConfig,
    STANDARD_VIEWS,
    render_component_references,
    get_component_images
)

from .detector import (
    ComponentDetector,
    DetectedComponent,
    DetectionResult,
    get_detector,
    detect_components,
    has_kb_components
)

from .retriever import (
    KnowledgeRetriever,
    RetrievalResult,
    RetrievalContext,
    get_retriever,
    reset_retriever,
    retrieve_components,
    get_kb_context
)

from .verifier import (
    VisualVerifier,
    VerificationResult,
    ViewComparison,
    verify_against_reference,
    quick_verify
)

from .component_filter import (
    ComponentFilter,
    AssemblyAnalyzer,
    FilterResult,
    FilteredComponent,
    ComponentRole,
    filter_detected_components,
    analyze_and_filter,
    SUBPART_PATTERNS,
    ALWAYS_SUBPART_MODULES,
    PARENT_CHILD_MAP
)

__all__ = [
    # Config
    "KB_CONFIG",
    "KBConfig",
    "VerificationThresholds",
    "DetectionStrategiesConfig",
    "get_config",
    "update_config",
    "NOPSCADLIB_DIR",
    "CHROMA_DB_DIR",
    "REFERENCE_IMAGES_DIR",
    "COMPONENT_INDEX_PATH",
    "DOCUMENTATION_PATH",
    "KB_DATA_DIR",
    "CATEGORY_KEYWORDS",
    "COMPONENT_ALIASES",

    # Indexer
    "ComponentInfo",
    "ComponentParameter",
    "NopSCADlibIndexer",
    "index_nopscadlib",
    "load_component_index",

    # Renderer
    "ComponentRenderer",
    "CameraConfig",
    "STANDARD_VIEWS",
    "render_component_references",
    "get_component_images",

    # Detector
    "ComponentDetector",
    "DetectedComponent",
    "DetectionResult",
    "get_detector",
    "detect_components",
    "has_kb_components",

    # Retriever
    "KnowledgeRetriever",
    "RetrievalResult",
    "RetrievalContext",
    "get_retriever",
    "reset_retriever",
    "retrieve_components",
    "get_kb_context",

    # Verifier
    "VisualVerifier",
    "VerificationResult",
    "ViewComparison",
    "verify_against_reference",
    "quick_verify",

    # Component Filter
    "ComponentFilter",
    "AssemblyAnalyzer",
    "FilterResult",
    "FilteredComponent",
    "ComponentRole",
    "filter_detected_components",
    "analyze_and_filter",
    "SUBPART_PATTERNS",
    "ALWAYS_SUBPART_MODULES",
    "PARENT_CHILD_MAP",
]


def is_kb_ready() -> bool:
    """Check if the knowledge base is ready to use."""
    return COMPONENT_INDEX_PATH.exists() and len(load_component_index()) > 0


def get_kb_status() -> dict:
    """Get status of the knowledge base."""
    import json
    import os

    components = load_component_index()

    # Count actual reference images
    image_count = 0
    if REFERENCE_IMAGES_DIR.exists():
        image_count = len(list(REFERENCE_IMAGES_DIR.glob("*.png")))

    # Check documentation
    docs_exist = DOCUMENTATION_PATH.exists()
    doc_count = 0
    if docs_exist:
        try:
            with open(DOCUMENTATION_PATH, encoding="utf-8") as f:
                doc_count = len(json.load(f))
        except (json.JSONDecodeError, OSError):
            doc_count = 0

    retriever_stats: dict = {}
    try:
        retriever_stats = get_retriever().get_statistics()
    except Exception as exc:
        retriever_stats = {"error": str(exc)[:300]}

    chroma_count = retriever_stats.get("indexed_count")
    index_len = len(components)
    openai_key = bool(os.environ.get("OPENAI_API_KEY"))
    chroma_ok = bool(retriever_stats.get("chroma_client_active"))

    # Semantic RAG is fully operational when Chroma opens cleanly, has vectors,
    # and OpenAI embeddings can run (retriever refuses Chroma's ONNX fallback).
    semantic_ready = (
        openai_key
        and chroma_ok
        and not retriever_stats.get("chroma_error")
        and isinstance(chroma_count, int)
        and chroma_count > 0
        and index_len > 0
    )

    index_chroma_aligned = (
        chroma_ok
        and isinstance(chroma_count, int)
        and index_len > 0
        and chroma_count == index_len
    )

    return {
        "ready": is_kb_ready(),
        "components_indexed": index_len,
        "nopscadlib_exists": NOPSCADLIB_DIR.exists(),
        "chroma_db_exists": CHROMA_DB_DIR.exists() and any(CHROMA_DB_DIR.iterdir()) if CHROMA_DB_DIR.exists() else False,
        "reference_images_exist": image_count > 0,
        "reference_images_count": image_count,
        "documentation_exists": docs_exist,
        "documentation_categories": doc_count,
        "retriever_stats": retriever_stats,
        "openai_api_key_set": openai_key,
        "semantic_search_ready": semantic_ready,
        "index_chroma_count_match": index_chroma_aligned,
    }
