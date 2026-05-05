#!/usr/bin/env python3
"""
Test script to verify Gemini API key is working.
"""

import os
import sys
from dotenv import load_dotenv

# Load .env file
load_dotenv()

# Add pipeline to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'pipeline'))

from core.llm_client import UnifiedLLMClient, create_unified_client

def test_gemini_api_key():
    """Test if Gemini API key is configured and working."""

    gemini_key = os.getenv("GEMINI_API_KEY")

    print("=" * 70)
    print("Gemini API Key Test")
    print("=" * 70)
    print()

    # Check if key is set
    if not gemini_key:
        print("✗ GEMINI_API_KEY is not set in .env file")
        print("  To enable Gemini, set: GEMINI_API_KEY=your-key-here")
        return False

    print(f"✓ GEMINI_API_KEY is set (starts with: {gemini_key[:20]}...)")
    print()

    # Create a unified client with Gemini
    try:
        client = create_unified_client(gemini_api_key=gemini_key)
        print("✓ UnifiedLLMClient created with Gemini key")
    except Exception as e:
        print(f"✗ Failed to create client: {e}")
        return False

    # Try a simple test call to Gemini
    print("\nTesting Gemini API with a simple prompt...")
    try:
        response = client.call_gemini(
            model="gemini-2.5-flash",
            messages=[
                {
                    "role": "user",
                    "content": "Say 'Hello from Gemini' in one sentence only."
                }
            ],
            temperature=0.7,
            max_tokens=100
        )

        print("✓ Gemini API call successful!")
        print(f"  Response: {response}")
        return True

    except Exception as e:
        print(f"✗ Gemini API call failed: {e}")

        # Provide helpful diagnostics
        if "401" in str(e) or "Unauthorized" in str(e):
            print("\n  → Your Gemini API key appears to be invalid or expired")
            print("  → Get a new key at: https://aistudio.google.com/app/apikey")
        elif "403" in str(e) or "Forbidden" in str(e):
            print("\n  → Your Gemini API key doesn't have access to this model")
            print("  → Check your API key permissions")
        elif "quota" in str(e).lower():
            print("\n  → You may have exceeded your Gemini API quota")
            print("  → Check your usage at: https://console.cloud.google.com/")

        return False


def test_enable_gemini_models():
    """Show which Gemini models can be used."""
    print("\n" + "=" * 70)
    print("Available Gemini Models for CRAFT")
    print("=" * 70)
    print()

    # These are the models that work with Gemini's REST API
    models = [
        ("gemini-2.0-flash", "Fast model, good for general tasks"),
        ("gemini-2.5-flash", "Latest flash model, improved performance"),
        ("gemini-3-pro-preview", "Preview model, better reasoning"),
    ]

    for model, description in models:
        print(f"• {model:25} - {description}")

    return True


if __name__ == "__main__":
    success = test_gemini_api_key()
    test_enable_gemini_models()

    print("\n" + "=" * 70)
    if success:
        print("✓ Gemini API is working and ready to use!")
        print("\nTo enable Gemini models in CRAFT:")
        print("  1. In .env, set a GEMINI_MODEL variable (optional)")
        print("  2. In app.py, set MODEL_REASONING='gemini-2.5-flash' or another model")
        print("  3. Or set individual model configs like:")
        print("     - MODEL_PRIMARY=gemini-2.5-flash")
        print("     - MODEL_SECONDARY=gemini-2.5-flash")
        print("     - MODEL_REASONING=gemini-3-pro-preview")
        print("     - MODEL_FAST=gemini-2.0-flash")
    else:
        print("✗ Gemini API test failed")
        print("\nSteps to fix:")
        print("  1. Get your Gemini API key: https://aistudio.google.com/app/apikey")
        print("  2. Add to .env: GEMINI_API_KEY=your-key-here")
        print("  3. Make sure you enable the Generative Language API")
    print("=" * 70)

    exit(0 if success else 1)
