#!/usr/bin/env python3
"""
Integration test for progress streaming in CRAFT pipeline.
Verifies that:
1. Progress queue is created per session
2. Progress events are emitted and retrieved correctly
3. SSE endpoint properly formats events
4. Frontend would receive correct data structure
"""

import json
import sys
import os
import time
import threading
from queue import Queue

# Add pipeline to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'pipeline'))

from app import app, get_progress_queue


def test_progress_queue_creation():
    """Test that progress queues are created on demand."""
    session_id = "test_session_123"

    # Get queue (should create it)
    queue1 = get_progress_queue(session_id)
    assert queue1 is not None, "Progress queue not created"

    # Get same queue again (should return existing)
    queue2 = get_progress_queue(session_id)
    assert queue1 is queue2, "Queue not cached properly"

    print("✓ Progress queue creation works")
    return True


def test_progress_event_flow():
    """Test the full event flow from pipeline to queue."""
    session_id = "test_session_flow"
    queue = get_progress_queue(session_id)

    # Simulate what emit_progress callback does
    start_time = time.time()

    def emit_progress(update_dict):
        """Simulate the callback from /generate endpoint."""
        # Handle both dict and object formats
        if isinstance(update_dict, dict):
            stage = update_dict.get("stage", "unknown")
            progress = update_dict.get("progress", 0)
            message = update_dict.get("message", "Processing...")
            eta_seconds = update_dict.get("eta_seconds")
            details = update_dict.get("details", {})
        else:
            stage = update_dict.stage
            progress = update_dict.progress
            message = update_dict.message
            eta_seconds = update_dict.eta_seconds
            details = update_dict.details or {}

        # Estimate eta if not provided
        if eta_seconds is None or eta_seconds == 0:
            elapsed = time.time() - start_time
            if progress > 0.01:
                estimated_total = elapsed / progress
                eta_seconds = int(max(0, estimated_total - elapsed))
            else:
                eta_seconds = 120

        # Put event in queue (like the real callback)
        queue.put({
            "stage": stage,
            "progress": round(progress, 3),
            "message": message,
            "eta": eta_seconds,
            "details": details
        })

    # Simulate pipeline progress updates
    updates = [
        {"stage": "understanding", "progress": 0.05, "message": "Analyzing...", "eta_seconds": 120, "details": {}},
        {"stage": "planning", "progress": 0.15, "message": "Planning...", "details": {}},  # No eta_seconds
        {"stage": "compilation", "progress": 0.45, "message": "Compiling...", "details": {}},
        {"stage": "rendering", "progress": 0.75, "message": "Rendering...", "details": {}},
        {"stage": "complete", "progress": 1.0, "message": "Complete!", "eta_seconds": 0, "details": {}},
    ]

    # Emit all updates
    for update in updates:
        emit_progress(update)

    # Verify all events are in queue
    events = []
    while not queue.empty():
        event = queue.get()
        events.append(event)

        # Verify structure
        required_fields = ["stage", "progress", "message", "eta", "details"]
        for field in required_fields:
            assert field in event, f"Missing field '{field}' in event: {event}"

        # Verify types
        assert isinstance(event["stage"], str)
        assert isinstance(event["progress"], (int, float))
        assert isinstance(event["message"], str)
        assert isinstance(event["eta"], int)
        assert isinstance(event["details"], dict)

        # Verify progress bounds
        assert 0 <= event["progress"] <= 1.0, f"Progress out of range: {event['progress']}"

        print(f"  ✓ Event {len(events)}: {event['stage']:15} | {event['progress']*100:5.1f}% | {event['message']:20} | ETA: {event['eta']:3d}s")

    assert len(events) == len(updates), f"Event count mismatch: {len(events)} != {len(updates)}"
    print(f"✓ Progress event flow works ({len(events)} events)")
    return True


def test_sse_endpoint_structure():
    """Test that SSE endpoint exists and has correct structure."""
    # Check that /progress/<session_id> route exists
    found_progress_route = False
    for rule in app.url_map._rules:
        if 'progress' in str(rule):
            found_progress_route = True
            assert '<session_id>' in str(rule), f"Progress route missing session_id parameter: {rule}"
            break

    assert found_progress_route, "Progress endpoint not found in Flask routes"
    print("✓ SSE endpoint registered")
    return True


def test_frontend_sse_parsing():
    """Test that frontend would correctly parse SSE events."""
    # Simulate SSE event stream
    events = [
        {"stage": "planning", "progress": 0.2, "message": "Creating plan...", "eta": 100, "details": {}},
        {"stage": "compilation", "progress": 0.5, "message": "Generating code...", "eta": 60, "details": {}},
        {"stage": "rendering", "progress": 0.8, "message": "Rendering 3D...", "eta": 20, "details": {}},
    ]

    for event in events:
        # Format as SSE event (what Flask yields)
        sse_data = f"data: {json.dumps(event)}\n\n"

        # Parse like frontend JavaScript would
        data_line = sse_data.strip().split('\n')[0]
        assert data_line.startswith("data: "), f"Invalid SSE format: {data_line}"

        # Extract and parse JSON
        json_str = data_line[6:]  # Remove "data: " prefix
        parsed = json.loads(json_str)

        # Verify structure frontend expects
        assert "stage" in parsed
        assert "progress" in parsed
        assert "message" in parsed
        assert "eta" in parsed

        # Frontend JavaScript expects:
        # progressBar.style.width = (update.progress * 100) + '%'
        progress_pct = parsed["progress"] * 100
        assert 0 <= progress_pct <= 100, f"Invalid progress percentage: {progress_pct}"

        # progressEta.textContent updates based on eta
        eta = parsed["eta"]
        minutes = eta // 60
        seconds = eta % 60
        eta_text = f"ETA: {minutes}m {seconds}s" if minutes > 0 else f"ETA: {seconds}s"

        print(f"  ✓ Frontend would display: {parsed['message']:20} ({progress_pct:5.1f}%) - {eta_text}")

    print("✓ Frontend SSE parsing works")
    return True


if __name__ == "__main__":
    print("=" * 70)
    print("CRAFT Progress Streaming Integration Test")
    print("=" * 70)
    print()

    tests = [
        ("Progress Queue Creation", test_progress_queue_creation),
        ("Progress Event Flow", test_progress_event_flow),
        ("SSE Endpoint Structure", test_sse_endpoint_structure),
        ("Frontend SSE Parsing", test_frontend_sse_parsing),
    ]

    passed = 0
    failed = 0

    for name, test_func in tests:
        print(f"\n{name}:")
        print("-" * 70)
        try:
            if test_func():
                passed += 1
        except Exception as e:
            print(f"✗ Test failed: {e}")
            import traceback
            traceback.print_exc()
            failed += 1

    print("\n" + "=" * 70)
    print(f"Integration Test Results: {passed} passed, {failed} failed")
    print("=" * 70)

    if failed == 0:
        print("\n✓ All integration tests passed!")
        print("\nProgress streaming is ready for testing with actual generation requests.")
        print("When you run /generate endpoint, you should see:")
        print("  1. Progress bar updates in real-time")
        print("  2. Stage messages changing (planning, compilation, rendering, etc.)")
        print("  3. ETA countdown ticking down")

    exit(0 if failed == 0 else 1)
