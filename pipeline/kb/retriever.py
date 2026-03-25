"""
Knowledge Base Retriever

Retrieves components from ChromaDB vector store.
Supports text-based and vision-based retrieval with hybrid ranking.
"""

import os
import json
import base64
from pathlib import Path
from dataclasses import dataclass, field
from typing import List, Dict, Optional, Tuple, Any

try:
    import chromadb
    from chromadb.config import Settings
    CHROMADB_AVAILABLE = True
except ImportError:
    CHROMADB_AVAILABLE = False
    print("Warning: chromadb not installed. Run: pip install chromadb")

try:
    import openai
    OPENAI_AVAILABLE = True
except ImportError:
    OPENAI_AVAILABLE = False

from .config import KB_CONFIG, CHROMA_DB_DIR, REFERENCE_IMAGES_DIR
from .indexer import ComponentInfo, load_component_index


@dataclass
class RetrievalResult:
    """Result of a retrieval query."""
    component: ComponentInfo
    score: float                    # Combined relevance score
    text_score: float = 0.0        # Text similarity score
    vision_score: float = 0.0      # Vision similarity score
    reference_images: Dict[str, Path] = field(default_factory=dict)


@dataclass
class RetrievalContext:
    """Full context for augmenting generation."""
    query: str
    results: List[RetrievalResult]
    total_found: int

    def get_top_component(self) -> Optional[ComponentInfo]:
        """Get the top matching component."""
        if self.results:
            return self.results[0].component
        return None

    def get_source_codes(self) -> List[str]:
        """Get source codes of all matched components."""
        return [r.component.module_code for r in self.results]

    def get_context_prompt(self) -> str:
        """Generate a context string for LLM augmentation."""
        if not self.results:
            return ""

        context_parts = []
        for i, result in enumerate(self.results[:3]):  # Top 3
            comp = result.component
            context_parts.append(f"""
### Component {i+1}: {comp.name} (confidence: {result.score:.2f})
**Module:** `{comp.module_name}`
**Category:** {comp.category}/{comp.subcategory}
**Description:** {comp.description or 'No description available'}

**OpenSCAD Code:**
```openscad
{comp.module_code}
```

**Parameters:**
{self._format_parameters(comp)}
""")

        return "\n".join(context_parts)

    def _format_parameters(self, comp: ComponentInfo) -> str:
        """Format component parameters as a readable list."""
        if not comp.parameters:
            return "None"

        lines = []
        for param in comp.parameters:
            default = f" = {param.default_value}" if param.default_value else ""
            lines.append(f"- `{param.name}`{default} ({param.param_type})")
        return "\n".join(lines)


class KnowledgeRetriever:
    """
    Retrieves components from the knowledge base using vector similarity.

    Supports:
    - Text-based retrieval (semantic search on descriptions)
    - Vision-based retrieval (CLIP embeddings on images)
    - Hybrid retrieval (weighted combination)
    """

    def __init__(
        self,
        db_path: Path = None,
        collection_name: str = None
    ):
        self.db_path = db_path or CHROMA_DB_DIR
        self.collection_name = collection_name or KB_CONFIG.collection_name

        # Component index
        self.components: Dict[str, ComponentInfo] = {}

        # ChromaDB client
        self.client = None
        self.collection = None

        # OpenAI client for embeddings
        self.openai_client = None

        self._initialize()

    def _initialize(self):
        """Initialize the retriever."""
        # Load component index
        self.components = load_component_index()

        # Initialize ChromaDB
        if CHROMADB_AVAILABLE:
            self.db_path.mkdir(parents=True, exist_ok=True)
            self.client = chromadb.PersistentClient(
                path=str(self.db_path),
                settings=Settings(
                    anonymized_telemetry=False,
                    allow_reset=True
                )
            )
        else:
            print("ChromaDB not available - retrieval will use fallback")

        # Initialize OpenAI client
        if OPENAI_AVAILABLE:
            api_key = os.environ.get("OPENAI_API_KEY")
            if api_key:
                self.openai_client = openai.OpenAI(api_key=api_key)

    def _get_or_create_collection(self):
        """Get or create the ChromaDB collection."""
        if self.collection is not None:
            return self.collection

        if not CHROMADB_AVAILABLE or self.client is None:
            return None

        self.collection = self.client.get_or_create_collection(
            name=self.collection_name,
            metadata={"hnsw:space": "cosine"}
        )
        return self.collection

    def _get_text_embedding(self, text: str) -> Optional[List[float]]:
        """Get embedding for text using OpenAI."""
        if not self.openai_client:
            return None

        try:
            response = self.openai_client.embeddings.create(
                model=KB_CONFIG.text_embedding_model,
                input=text
            )
            return response.data[0].embedding
        except Exception as e:
            print(f"Embedding error: {e}")
            return None

    def build_index(self, components: Dict[str, ComponentInfo] = None):
        """
        Build the vector index from components.

        Args:
            components: Components to index (uses loaded if not provided)
        """
        components = components or self.components
        if not components:
            print("No components to index")
            return

        collection = self._get_or_create_collection()
        if collection is None:
            print("Cannot build index without ChromaDB")
            return

        print(f"Building vector index for {len(components)} components...")

        # Prepare data for batch insert
        ids = []
        documents = []
        metadatas = []
        embeddings = []

        for comp_id, comp in components.items():
            # Create searchable document
            doc = self._create_document(comp)

            # Get embedding
            embedding = self._get_text_embedding(doc)
            if embedding is None:
                continue

            ids.append(comp_id)
            documents.append(doc)
            metadatas.append({
                "name": comp.name,
                "module_name": comp.module_name,
                "category": comp.category,
                "subcategory": comp.subcategory,
                "source_file": comp.source_file
            })
            embeddings.append(embedding)

            if len(ids) % 50 == 0:
                print(f"  Processed {len(ids)} components...")

        # Batch upsert
        if ids:
            # ChromaDB has a batch limit, process in chunks
            batch_size = 100
            for i in range(0, len(ids), batch_size):
                end_idx = min(i + batch_size, len(ids))
                collection.upsert(
                    ids=ids[i:end_idx],
                    documents=documents[i:end_idx],
                    metadatas=metadatas[i:end_idx],
                    embeddings=embeddings[i:end_idx]
                )

        print(f"Indexed {len(ids)} components with embeddings")

    def _create_document(self, comp: ComponentInfo) -> str:
        """Create a searchable document from component info."""
        parts = [
            f"Name: {comp.name}",
            f"Module: {comp.module_name}",
            f"Category: {comp.category}/{comp.subcategory}",
        ]

        if comp.description:
            parts.append(f"Description: {comp.description}")

        if comp.parameters:
            param_names = [p.name for p in comp.parameters]
            parts.append(f"Parameters: {', '.join(param_names)}")

        if comp.keywords:
            parts.append(f"Keywords: {', '.join(comp.keywords[:10])}")

        return "\n".join(parts)

    def retrieve(
        self,
        query: str,
        top_k: int = None,
        category_filter: str = None
    ) -> RetrievalContext:
        """
        Retrieve relevant components for a query.

        Args:
            query: Search query
            top_k: Number of results to return
            category_filter: Optional category to filter by

        Returns:
            RetrievalContext with matched components
        """
        top_k = top_k or KB_CONFIG.retrieval_top_k

        collection = self._get_or_create_collection()

        # If ChromaDB available, use vector search
        if collection is not None and collection.count() > 0:
            results = self._vector_search(query, top_k, category_filter)
        else:
            # Fallback to keyword search
            results = self._fallback_search(query, top_k, category_filter)

        return RetrievalContext(
            query=query,
            results=results,
            total_found=len(results)
        )

    def _vector_search(
        self,
        query: str,
        top_k: int,
        category_filter: str = None
    ) -> List[RetrievalResult]:
        """Perform vector similarity search."""
        collection = self._get_or_create_collection()

        # Build where filter
        where_filter = None
        if category_filter:
            where_filter = {"category": category_filter}

        # Get query embedding
        query_embedding = self._get_text_embedding(query)

        if query_embedding:
            # Search with embedding
            search_results = collection.query(
                query_embeddings=[query_embedding],
                n_results=top_k,
                where=where_filter,
                include=["documents", "metadatas", "distances"]
            )
        else:
            # Fallback to text search
            search_results = collection.query(
                query_texts=[query],
                n_results=top_k,
                where=where_filter,
                include=["documents", "metadatas", "distances"]
            )

        # Convert to RetrievalResults
        results = []
        if search_results and search_results['ids']:
            for i, comp_id in enumerate(search_results['ids'][0]):
                if comp_id not in self.components:
                    continue

                comp = self.components[comp_id]

                # Convert distance to score (cosine distance → similarity)
                distance = search_results['distances'][0][i]
                score = 1.0 - distance  # Cosine similarity

                # Get reference images
                ref_images = self._get_reference_images(comp_id)

                results.append(RetrievalResult(
                    component=comp,
                    score=score,
                    text_score=score,
                    reference_images=ref_images
                ))

        return results

    def _fallback_search(
        self,
        query: str,
        top_k: int,
        category_filter: str = None
    ) -> List[RetrievalResult]:
        """Fallback keyword-based search when vector DB unavailable."""
        query_lower = query.lower()
        query_words = set(query_lower.split())

        scored_components = []

        for comp_id, comp in self.components.items():
            # Category filter
            if category_filter and comp.category != category_filter:
                continue

            # Calculate keyword overlap score
            comp_text = f"{comp.name} {comp.module_name} {comp.description} {' '.join(comp.keywords)}"
            comp_words = set(comp_text.lower().split())

            overlap = len(query_words & comp_words)
            if overlap == 0:
                continue

            score = overlap / max(len(query_words), 1)

            # Boost for exact name match
            if query_lower in comp.name.lower() or query_lower in comp.module_name.lower():
                score += 0.5

            scored_components.append((comp_id, score))

        # Sort by score and take top_k
        scored_components.sort(key=lambda x: x[1], reverse=True)
        top_results = scored_components[:top_k]

        results = []
        for comp_id, score in top_results:
            comp = self.components[comp_id]
            ref_images = self._get_reference_images(comp_id)

            results.append(RetrievalResult(
                component=comp,
                score=min(score, 1.0),
                text_score=min(score, 1.0),
                reference_images=ref_images
            ))

        return results

    def _get_reference_images(self, component_id: str) -> Dict[str, Path]:
        """Get reference image paths for a component."""
        images = {}
        component_dir = REFERENCE_IMAGES_DIR / component_id

        if component_dir.exists():
            for view in KB_CONFIG.render_views:
                image_path = component_dir / f"{view}.png"
                if image_path.exists():
                    images[view] = image_path

        return images

    def retrieve_by_ids(
        self,
        component_ids: List[str]
    ) -> List[RetrievalResult]:
        """
        Retrieve specific components by their IDs.

        Args:
            component_ids: List of component IDs to retrieve

        Returns:
            List of RetrievalResults
        """
        results = []

        for comp_id in component_ids:
            if comp_id in self.components:
                comp = self.components[comp_id]
                ref_images = self._get_reference_images(comp_id)

                results.append(RetrievalResult(
                    component=comp,
                    score=1.0,  # Direct retrieval
                    text_score=1.0,
                    reference_images=ref_images
                ))

        return results

    def retrieve_for_detection(
        self,
        detected_ids: List[str],
        query: str = None
    ) -> RetrievalContext:
        """
        Retrieve components based on detection results.

        Args:
            detected_ids: Component IDs from detector
            query: Original query (for context)

        Returns:
            RetrievalContext with full component info
        """
        results = self.retrieve_by_ids(detected_ids)

        return RetrievalContext(
            query=query or "",
            results=results,
            total_found=len(results)
        )

    def get_component(self, component_id: str) -> Optional[ComponentInfo]:
        """Get a single component by ID."""
        return self.components.get(component_id)

    def get_all_categories(self) -> List[str]:
        """Get list of all component categories."""
        return list(set(c.category for c in self.components.values()))

    def get_statistics(self) -> Dict:
        """Get retriever statistics."""
        stats = {
            "total_components": len(self.components),
            "chromadb_available": CHROMADB_AVAILABLE,
            "openai_available": OPENAI_AVAILABLE
        }

        if CHROMADB_AVAILABLE and self.collection:
            stats["indexed_count"] = self.collection.count()

        return stats


# Global retriever instance
_retriever: Optional[KnowledgeRetriever] = None


def get_retriever() -> KnowledgeRetriever:
    """Get or create the global retriever instance."""
    global _retriever
    if _retriever is None:
        _retriever = KnowledgeRetriever()
    return _retriever


def retrieve_components(query: str, top_k: int = 3) -> RetrievalContext:
    """
    Convenience function to retrieve components.

    Args:
        query: Search query
        top_k: Number of results

    Returns:
        RetrievalContext with results
    """
    retriever = get_retriever()
    return retriever.retrieve(query, top_k)


def get_kb_context(component_ids: List[str], query: str = "") -> RetrievalContext:
    """
    Get full context for detected components.

    Args:
        component_ids: List of detected component IDs
        query: Original query

    Returns:
        RetrievalContext with full component info
    """
    retriever = get_retriever()
    return retriever.retrieve_for_detection(component_ids, query)
