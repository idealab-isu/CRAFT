#!/usr/bin/env python3
"""
Test script for the NopSCADlib Knowledge Base system.
Run this after build_knowledge_base.py to verify everything works.
"""

import sys
import json
from pathlib import Path

# Add parent to path
sys.path.insert(0, str(Path(__file__).parent.parent))

from kb import KB_DATA_DIR, COMPONENT_INDEX_PATH, get_kb_status
from kb.detector import ComponentDetector


def test_kb_status():
    """Check if KB is ready."""
    print("=" * 60)
    print("Testing KB Status")
    print("=" * 60)

    # Use the module-level constant
    if COMPONENT_INDEX_PATH.exists():
        with open(COMPONENT_INDEX_PATH) as f:
            data = json.load(f)
        print(f"✓ Component index found: {len(data.get('components', []))} components")

        # Show full status
        status = get_kb_status()
        print(f"  Reference images: {status.get('reference_images_count', 0)} available")
        print(f"  Documentation: {status.get('documentation_categories', 0)} categories")
        print(f"  Vector store: {'Ready' if status.get('chroma_db_exists') else 'Not built'}")

        return data.get('components', [])
    else:
        print(f"✗ No component index found at {COMPONENT_INDEX_PATH}")
        print("\nRun first: python scripts/build_knowledge_base.py")
        return []


def test_component_detection(components):
    """Test component detection from prompts."""
    print("\n" + "=" * 60)
    print("Testing Component Detection")
    print("=" * 60)

    # Initialize detector and load components properly (converts dicts to ComponentInfo)
    detector = ComponentDetector()
    detector.load_components()

    test_prompts = [
        "Create a bracket with an SG90 servo motor mount",
        "Design a case for a NEMA17 stepper motor",
        "Make a housing for a 6001 ball bearing",
        "Build an enclosure with a 40mm fan mount",
        "Simple box with a lid",  # No KB component
        "Design something using an Arduino Nano",
        "Create a mount for an M8 nut",
    ]

    for prompt in test_prompts:
        print(f"\nPrompt: \"{prompt}\"")
        result = detector.detect(prompt)

        if result.has_kb_components:
            print(f"  ✓ Detected {len(result.detected_components)} component(s):")
            for comp in result.detected_components:
                print(f"    - {comp.component_id} (confidence: {comp.confidence:.2f})")
                print(f"      matched: \"{comp.matched_text}\" via {comp.match_type}")
        else:
            print("  - No KB components detected")


def test_component_lookup(components):
    """Test looking up specific components."""
    print("\n" + "=" * 60)
    print("Testing Component Lookup")
    print("=" * 60)

    if not components:
        print("No components to look up")
        return

    # Components can be either a dict or list depending on source
    if isinstance(components, dict):
        # From JSON file: {'components': {...}}
        comp_dict = components
        samples = list(comp_dict.items())[:5]
        for comp_id, comp in samples:
            print(f"\nComponent: {comp_id}")
            print(f"  Name: {comp.get('name', 'N/A')}")
            print(f"  Category: {comp.get('category', 'N/A')}")
            print(f"  File: {comp.get('source_file', comp.get('file_path', 'N/A'))}")
            params = comp.get('parameters', [])
            if params:
                print(f"  Parameters: {len(params)}")
                for p in params[:3]:
                    print(f"    - {p.get('name', '?')}: {p.get('default', 'N/A')}")
    else:
        # From list
        samples = components[:5] if len(components) > 5 else components
        for comp in samples:
            print(f"\nComponent: {comp.get('id', 'unknown')}")
            print(f"  Name: {comp.get('name', 'N/A')}")
            print(f"  Category: {comp.get('category', 'N/A')}")
            print(f"  File: {comp.get('source_file', comp.get('file_path', 'N/A'))}")
            params = comp.get('parameters', [])
            if params:
                print(f"  Parameters: {len(params)}")
                for p in params[:3]:
                    print(f"    - {p.get('name', '?')}: {p.get('default', 'N/A')}")


def test_api_endpoints():
    """Test that API endpoints respond (requires running server)."""
    print("\n" + "=" * 60)
    print("Testing API Endpoints")
    print("=" * 60)

    try:
        import requests
        base_url = "http://localhost:5000"

        # Test /kb/status
        print("\nGET /kb/status")
        try:
            resp = requests.get(f"{base_url}/kb/status", timeout=5)
            if resp.ok:
                data = resp.json()
                print(f"  ✓ Status: available={data.get('available')}, components={data.get('components_indexed')}")
            else:
                print(f"  ✗ Error: {resp.status_code}")
        except requests.exceptions.ConnectionError:
            print("  - Server not running (start with: python app.py)")

        # Test /kb/search
        print("\nPOST /kb/search")
        try:
            resp = requests.post(
                f"{base_url}/kb/search",
                json={"query": "servo motor"},
                timeout=5
            )
            if resp.ok:
                data = resp.json()
                results = data.get('results', [])
                print(f"  ✓ Found {len(results)} results for 'servo motor'")
                for r in results[:3]:
                    print(f"    - {r.get('id')}: {r.get('name')}")
            else:
                print(f"  ✗ Error: {resp.status_code}")
        except requests.exceptions.ConnectionError:
            print("  - Server not running")

    except ImportError:
        print("  - requests library not installed")


def test_full_pipeline():
    """Show how to test full pipeline integration."""
    print("\n" + "=" * 60)
    print("Testing Full Pipeline (Instructions)")
    print("=" * 60)

    print("""
To test the full KB-augmented pipeline:

1. Start the server:
   cd llm_to_cad/craft
   python app.py

2. Use the API with a KB component:

   curl -X POST http://localhost:5000/generate \\
     -H "Content-Type: application/json" \\
     -d '{"prompt": "Create a bracket with an SG90 servo motor mount"}'

3. The system will:
   - Auto-detect "SG90" from your prompt
   - Retrieve exact NopSCADlib code for SG90
   - Augment the LLM prompt with this code
   - Generate OpenSCAD that uses the real SG90 model

4. Check /kb/status endpoint:
   curl http://localhost:5000/kb/status

5. Search components directly:
   curl -X POST http://localhost:5000/kb/search \\
     -H "Content-Type: application/json" \\
     -d '{"query": "stepper motor"}'
""")


def main():
    print("\n🔧 NopSCADlib Knowledge Base Test Suite\n")

    # Test 1: Check status
    components = test_kb_status()

    # Test 2: Component detection
    test_component_detection(components)

    # Test 3: Component lookup
    test_component_lookup(components)

    # Test 4: API (if server running)
    test_api_endpoints()

    # Test 5: Full pipeline instructions
    test_full_pipeline()

    print("\n" + "=" * 60)
    print("Test Complete!")
    print("=" * 60)


if __name__ == "__main__":
    main()
