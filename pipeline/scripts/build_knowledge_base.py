#!/usr/bin/env python3
"""
NopSCADlib Knowledge Base Builder

One-time script to build the knowledge base:
1. Clone/update NopSCADlib repository
2. Parse and index all components with documentation
3. Download reference images from NopSCADlib repo
4. Build vector embeddings in ChromaDB

Usage:
    python build_knowledge_base.py [options]

Options:
    --skip-images    Skip downloading reference images
    --skip-vectors   Skip building vector embeddings
    --categories     Comma-separated categories to index (default: vitamins,printed)
    --force          Force rebuild even if index exists
"""

import os
import sys
import argparse
import time
from pathlib import Path

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent))

# Load .env file for API keys
try:
    from dotenv import load_dotenv
    # Look for .env in multiple locations
    env_paths = [
        Path(__file__).parent.parent / ".env",  # craft/.env
        Path(__file__).parent.parent.parent / ".env",  # llm_to_cad/.env
        Path.cwd() / ".env",  # current directory
    ]
    for env_path in env_paths:
        if env_path.exists():
            load_dotenv(env_path)
            print(f"Loaded environment from {env_path}")
            break
except ImportError:
    print("python-dotenv not installed, using environment variables directly")

from kb import (
    KB_CONFIG,
    KB_DATA_DIR,
    NOPSCADLIB_DIR,
    COMPONENT_INDEX_PATH,
    NopSCADlibIndexer,
    ComponentRenderer,
    KnowledgeRetriever,
    load_component_index
)


def parse_args():
    parser = argparse.ArgumentParser(
        description="Build NopSCADlib Knowledge Base for CRAFT"
    )
    parser.add_argument(
        "--skip-images",
        action="store_true",
        help="Skip downloading reference images"
    )
    parser.add_argument(
        "--skip-vectors",
        action="store_true",
        help="Skip building vector embeddings (no semantic search)"
    )
    parser.add_argument(
        "--categories",
        type=str,
        default="vitamins,printed",
        help="Comma-separated categories to index"
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="Force rebuild even if index exists"
    )
    parser.add_argument(
        "--parse-docs",
        action="store_true",
        default=True,
        help="Parse documentation from readme.md (default: True)"
    )
    return parser.parse_args()


def step_clone_repo():
    """Step 1: Clone or update NopSCADlib repository."""
    print("\n" + "="*60)
    print("STEP 1: Clone/Update NopSCADlib Repository")
    print("="*60)

    indexer = NopSCADlibIndexer()
    success = indexer.clone_or_update_repo()

    if success:
        print(f"✓ NopSCADlib ready at {NOPSCADLIB_DIR}")
    else:
        print("✗ Failed to get NopSCADlib repository")
        return False

    return True


def step_index_components(categories: list, force: bool = False):
    """Step 2: Parse and index components."""
    print("\n" + "="*60)
    print("STEP 2: Index Components")
    print("="*60)

    if COMPONENT_INDEX_PATH.exists() and not force:
        print(f"Index already exists at {COMPONENT_INDEX_PATH}")
        existing = load_component_index()
        print(f"Contains {len(existing)} components")

        response = input("Rebuild index? [y/N]: ").strip().lower()
        if response != 'y':
            print("Using existing index")
            return existing

    print(f"Indexing categories: {categories}")

    indexer = NopSCADlibIndexer()
    if not indexer.clone_or_update_repo():
        print("✗ NopSCADlib not available")
        return {}

    components = indexer.index_all(categories)
    indexer.save_index()

    # Print statistics
    stats = indexer.get_statistics()
    print(f"\n✓ Indexed {stats['total']} components")
    print(f"  By category: {stats['by_category']}")

    return components


def step_download_images(components: dict, skip: bool = False):
    """Step 3: Download reference images from NopSCADlib repository."""
    print("\n" + "="*60)
    print("STEP 3: Download Reference Images")
    print("="*60)

    if skip:
        print("Skipping image download (--skip-images flag)")
        return

    if not components:
        print("No components to download images for")
        return

    import shutil
    import urllib.request
    from urllib.error import HTTPError, URLError

    # NopSCADlib has pre-rendered images at tests/png/
    # Images are named by category: servo_motors.png, stepper_motors.png, etc.

    images_dir = KB_DATA_DIR / "reference_images"
    images_dir.mkdir(parents=True, exist_ok=True)

    # First, try to copy from local clone
    local_png_dir = NOPSCADLIB_DIR / "tests" / "png"

    if local_png_dir.exists():
        print(f"Copying images from local NopSCADlib clone...")
        png_files = list(local_png_dir.glob("*.png"))
        copied = 0

        for png_file in png_files:
            dest = images_dir / png_file.name
            if not dest.exists():
                shutil.copy2(png_file, dest)
                copied += 1

        print(f"✓ Copied {copied} new images ({len(png_files)} total available)")
    else:
        # Fall back to downloading from GitHub
        print("Local images not found, downloading from GitHub...")
        base_url = "https://raw.githubusercontent.com/nophead/NopSCADlib/master/tests/png"

        # Get unique categories from components
        categories = set()
        for comp_id, comp in components.items():
            cat = comp.get('category', comp.category if hasattr(comp, 'category') else None)
            if cat:
                categories.add(cat)

        downloaded = 0
        failed = 0

        for category in categories:
            # Category images are usually named like: servo_motors.png, stepper_motors.png
            image_name = f"{category}.png"
            dest = images_dir / image_name

            if dest.exists():
                continue

            url = f"{base_url}/{image_name}"
            try:
                urllib.request.urlretrieve(url, dest)
                downloaded += 1
                print(f"  ✓ Downloaded {image_name}")
            except (HTTPError, URLError) as e:
                failed += 1
                print(f"  ✗ Failed to download {image_name}: {e}")

        print(f"\n✓ Downloaded {downloaded} images, {failed} failed")

    # List available images
    available = list(images_dir.glob("*.png"))
    print(f"\nReference images available: {len(available)}")

    # Also download libtest.png (main overview image)
    libtest_url = "https://raw.githubusercontent.com/nophead/NopSCADlib/master/libtest.png"
    libtest_dest = images_dir / "libtest.png"
    if not libtest_dest.exists():
        try:
            if (NOPSCADLIB_DIR / "libtest.png").exists():
                shutil.copy2(NOPSCADLIB_DIR / "libtest.png", libtest_dest)
            else:
                urllib.request.urlretrieve(libtest_url, libtest_dest)
            print("  ✓ Downloaded main library overview image")
        except Exception as e:
            print(f"  ✗ Failed to get libtest.png: {e}")


def step_build_vectors(components: dict, skip: bool = False):
    """Step 4: Build vector embeddings."""
    print("\n" + "="*60)
    print("STEP 4: Build Vector Embeddings")
    print("="*60)

    if skip:
        print("Skipping vector build (--skip-vectors flag)")
        return

    if not components:
        print("No components to index")
        return

    # Check for OpenAI API key
    if not os.environ.get("OPENAI_API_KEY"):
        print("⚠ OPENAI_API_KEY not set")
        print("  Vector embeddings require OpenAI API")
        print("  Set the environment variable and re-run, or use --skip-vectors")
        return

    print(f"Building embeddings for {len(components)} components...")

    retriever = KnowledgeRetriever()
    retriever.components = components
    retriever.build_index(components)

    stats = retriever.get_statistics()
    print(f"\n✓ Vector index built")
    print(f"  Indexed: {stats.get('indexed_count', 'N/A')} components")


def print_summary(components: dict):
    """Print final summary."""
    print("\n" + "="*60)
    print("KNOWLEDGE BASE BUILD COMPLETE")
    print("="*60)

    print(f"\nComponents indexed: {len(components)}")
    print(f"Index file: {COMPONENT_INDEX_PATH}")

    # Check what's ready
    from kb import get_kb_status
    status = get_kb_status()

    print("\nStatus:")
    print(f"  ✓ Component index: {'Ready' if status['components_indexed'] > 0 else 'Not built'}")
    print(f"  {'✓' if status['reference_images_exist'] else '○'} Reference images: "
          f"{'Available' if status['reference_images_exist'] else 'Not rendered'}")
    print(f"  {'✓' if status['chroma_db_exists'] else '○'} Vector store: "
          f"{'Available' if status['chroma_db_exists'] else 'Not built'}")

    print("\nThe knowledge base is ready to use!")
    print("Components will be automatically detected in user prompts.")


def step_parse_documentation():
    """Step 2.5: Parse documentation from readme.md."""
    print("\n" + "="*60)
    print("STEP 2.5: Parse Documentation from README")
    print("="*60)

    readme_path = NOPSCADLIB_DIR / "readme.md"
    if not readme_path.exists():
        print("readme.md not found, skipping documentation parsing")
        return {}

    docs = {}
    current_section = None
    current_content = []

    print("Parsing NopSCADlib documentation...")

    try:
        with open(readme_path, 'r', encoding='utf-8') as f:
            content = f.read()

        # Parse sections - each component category has an anchor like <a name="servo_motors">
        import re

        # Find all section anchors and their content
        sections = re.split(r'<a name="([^"]+)">', content)

        for i in range(1, len(sections), 2):
            if i + 1 < len(sections):
                section_name = sections[i]
                section_content = sections[i + 1]

                # Extract until next anchor or end
                end_idx = section_content.find('<a name="')
                if end_idx > 0:
                    section_content = section_content[:end_idx]

                # Extract key info
                doc_entry = {
                    'name': section_name,
                    'raw_markdown': section_content[:5000],  # Limit size
                    'properties': [],
                    'modules': [],
                    'vitamins': [],
                    'image_path': f"tests/png/{section_name}.png"
                }

                # Extract properties table
                props_match = re.search(
                    r'### Properties\s*\n\|[^\n]+\n\|[^\n]+\n((?:\|[^\n]+\n)+)',
                    section_content
                )
                if props_match:
                    for line in props_match.group(1).strip().split('\n'):
                        parts = line.split('|')
                        if len(parts) >= 3:
                            func = parts[1].strip().strip('`')
                            desc = parts[2].strip()
                            doc_entry['properties'].append({'function': func, 'description': desc})

                # Extract modules table
                mods_match = re.search(
                    r'### Modules\s*\n\|[^\n]+\n\|[^\n]+\n((?:\|[^\n]+\n)+)',
                    section_content
                )
                if mods_match:
                    for line in mods_match.group(1).strip().split('\n'):
                        parts = line.split('|')
                        if len(parts) >= 3:
                            mod = parts[1].strip().strip('`')
                            desc = parts[2].strip()
                            doc_entry['modules'].append({'module': mod, 'description': desc})

                # Extract vitamins table
                vit_match = re.search(
                    r'### Vitamins\s*\n\|[^\n]+\n\|[^\n]+\n((?:\|[^\n]+\n)+)',
                    section_content
                )
                if vit_match:
                    for line in vit_match.group(1).strip().split('\n'):
                        parts = line.split('|')
                        if len(parts) >= 4:
                            qty = parts[1].strip()
                            call = parts[2].strip().strip('`')
                            entry = parts[3].strip()
                            doc_entry['vitamins'].append({
                                'qty': qty,
                                'module_call': call,
                                'bom_entry': entry
                            })

                docs[section_name] = doc_entry

        print(f"✓ Parsed documentation for {len(docs)} component categories")

        # Save docs to file
        import json
        docs_path = KB_DATA_DIR / "documentation.json"
        with open(docs_path, 'w') as f:
            json.dump(docs, f, indent=2)
        print(f"  Saved to {docs_path}")

        return docs

    except Exception as e:
        print(f"✗ Error parsing documentation: {e}")
        return {}


def main():
    args = parse_args()

    print("="*60)
    print("NopSCADlib Knowledge Base Builder")
    print("="*60)
    print(f"\nConfiguration:")
    print(f"  Categories: {args.categories}")
    print(f"  Skip images: {args.skip_images}")
    print(f"  Skip vectors: {args.skip_vectors}")
    print(f"  Force rebuild: {args.force}")

    categories = [c.strip() for c in args.categories.split(",")]

    # Step 1: Clone repo
    if not step_clone_repo():
        print("\nBuild failed at Step 1")
        sys.exit(1)

    # Step 2: Index components
    components = step_index_components(categories, args.force)
    if not components:
        print("\nNo components indexed. Check NopSCADlib structure.")
        sys.exit(1)

    # Step 2.5: Parse documentation
    if args.parse_docs:
        docs = step_parse_documentation()
    else:
        docs = {}

    # Step 3: Download images (from NopSCADlib's pre-rendered images)
    step_download_images(components, skip=args.skip_images)

    # Step 4: Build vectors
    step_build_vectors(components, skip=args.skip_vectors)

    # Summary
    print_summary(components)


if __name__ == "__main__":
    main()
