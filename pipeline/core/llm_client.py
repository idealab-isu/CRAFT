"""
Unified LLM Client Wrapper

This module provides a unified interface for calling different LLM providers:
- OpenAI (GPT-4o, GPT-5.1, GPT-5.2)
- Google Gemini (gemini-2.0-flash, gemini-2.5-flash, gemini-3-pro-preview)

All providers are wrapped to provide a consistent interface similar to OpenAI's API.

For GPT-5.2 vision, we use the Responses API with input_image format.
For GPT-4o/GPT-5.1 vision, we use Chat Completions API with image_url format.
"""

import os
import base64
import json
import time
import requests
from typing import Any, Dict, List, Optional, Union
from dataclasses import dataclass


@dataclass
class ChatMessage:
    """Represents a chat message."""
    role: str
    content: str


@dataclass
class ChatChoice:
    """Represents a chat completion choice."""
    message: ChatMessage


@dataclass
class ChatCompletion:
    """Represents a chat completion response."""
    choices: List[ChatChoice]


@dataclass
class ResponsesOutput:
    """Represents a Responses API output."""
    output_text: str


# Models that require the Responses API for vision (input_image format)
RESPONSES_API_VISION_MODELS = {"gpt-5.2"}

# Models that use max_completion_tokens instead of max_tokens
NEW_API_MODELS = {"gpt-5.1", "gpt-5.2", "o1", "o1-mini", "o1-preview", "o3", "o3-mini"}


class ResponsesAPI:
    """
    Wrapper for OpenAI Responses API (used for GPT-5.2 vision).

    The Responses API uses input_image format instead of image_url.
    """

    def __init__(self, openai_client):
        self.openai_client = openai_client

    def create(
        self,
        model: str,
        input: List[Dict[str, Any]],
        temperature: float = 0.2,
        max_output_tokens: Optional[int] = None,
        **kwargs
    ) -> ResponsesOutput:
        """
        Create a response using OpenAI Responses API.

        Args:
            model: Model name (e.g., "gpt-5.2")
            input: List of input messages with content parts
            temperature: Sampling temperature
            max_output_tokens: Maximum tokens to generate
            **kwargs: Additional parameters

        Returns:
            ResponsesOutput with output_text
        """
        if not self.openai_client:
            raise ValueError("OpenAI client not initialized")

        call_kwargs = {
            "model": model,
            "input": input,
        }

        # Only add temperature if model supports it (not reasoning models)
        if model not in {"o1", "o1-mini", "o1-preview", "o3", "o3-mini"}:
            call_kwargs["temperature"] = temperature

        if max_output_tokens:
            call_kwargs["max_output_tokens"] = max_output_tokens

        call_kwargs.update(kwargs)

        # Call the Responses API
        response = self.openai_client.responses.create(**call_kwargs)

        # Extract the output text
        output_text = response.output_text if hasattr(response, 'output_text') else ""

        return ResponsesOutput(output_text=output_text)


class UnifiedLLMClient:
    """
    Unified client for multiple LLM providers.

    Provides a consistent interface similar to OpenAI's API, but supports
    multiple providers including OpenAI and Google Gemini.

    For vision tasks:
    - GPT-5.2: Uses Responses API with input_image format
    - GPT-4o/GPT-5.1: Uses Chat Completions API with image_url format
    - Gemini: Uses native Gemini API with inline_data format
    """

    # Model to provider mapping
    MODEL_PROVIDERS = {
        "gpt-4o": "openai",
        "gpt-5.1": "openai",
        "gpt-5.2": "openai",
        "o1": "openai",
        "o1-mini": "openai",
        "gemini-2.0-flash": "gemini",
        "gemini-2.5-flash": "gemini",
        "gemini-3-pro-preview": "gemini",
    }

    # Gemini API model names
    GEMINI_MODEL_NAMES = {
        "gemini-2.0-flash": "gemini-2.0-flash",
        "gemini-2.5-flash": "gemini-2.0-flash-exp",
        "gemini-3-pro-preview": "gemini-exp-1206",
    }

    def __init__(self, openai_client=None, gemini_api_key: Optional[str] = None):
        """
        Initialize the unified LLM client.

        Args:
            openai_client: OpenAI client instance (optional)
            gemini_api_key: Gemini API key (optional, defaults to env var)
        """
        self.openai_client = openai_client
        self.gemini_api_key = gemini_api_key or os.getenv("GEMINI_API_KEY")
        self._responses_api = None

    @property
    def chat(self):
        """Provide chat interface for API compatibility."""
        return self

    @property
    def completions(self):
        """Provide completions interface for API compatibility."""
        return self

    @property
    def responses(self):
        """Provide Responses API interface for GPT-5.2 vision."""
        if self._responses_api is None:
            self._responses_api = ResponsesAPI(self.openai_client)
        return self._responses_api

    def create(
        self,
        model: str,
        messages: List[Dict[str, str]],
        temperature: float = 0.2,
        response_format: Optional[Dict[str, str]] = None,
        max_tokens: Optional[int] = None,
        **kwargs
    ) -> ChatCompletion:
        """
        Create a chat completion using the appropriate provider.

        Args:
            model: Model name (e.g., "gpt-4o", "gemini-2.5-flash")
            messages: List of message dicts with "role" and "content"
            temperature: Sampling temperature
            response_format: Optional response format (e.g., {"type": "json_object"})
            max_tokens: Maximum tokens to generate
            **kwargs: Additional provider-specific parameters

        Returns:
            ChatCompletion object with consistent structure
        """
        provider = self.MODEL_PROVIDERS.get(model, "openai")

        if provider == "openai":
            return self._call_openai(model, messages, temperature, response_format, max_tokens, **kwargs)
        elif provider == "gemini":
            return self._call_gemini(model, messages, temperature, response_format, max_tokens, **kwargs)
        else:
            raise ValueError(f"Unsupported provider for model: {model}")

    def _call_openai(
        self,
        model: str,
        messages: List[Dict[str, Any]],
        temperature: float,
        response_format: Optional[Dict[str, str]],
        max_tokens: Optional[int],
        **kwargs
    ) -> ChatCompletion:
        """
        Call OpenAI Chat Completions API.

        Handles token parameter selection based on model:
        - GPT-5.x, o1, o3: use max_completion_tokens
        - GPT-4o and older: use max_tokens
        """
        if not self.openai_client:
            raise ValueError("OpenAI client not initialized")

        call_kwargs = {
            "model": model,
            "messages": messages,
        }

        # Only add temperature for models that support it
        if model not in {"o1", "o1-mini", "o1-preview", "o3", "o3-mini"}:
            call_kwargs["temperature"] = temperature

        if response_format:
            call_kwargs["response_format"] = response_format

        # Handle token parameters - prioritize what's explicitly passed in kwargs
        # Remove any token params from kwargs to handle them explicitly
        max_completion_tokens = kwargs.pop("max_completion_tokens", None)

        if max_completion_tokens is not None:
            # Explicitly passed max_completion_tokens takes priority
            call_kwargs["max_completion_tokens"] = max_completion_tokens
        elif max_tokens is not None:
            # Use the right parameter based on model
            if model in NEW_API_MODELS:
                call_kwargs["max_completion_tokens"] = max_tokens
            else:
                call_kwargs["max_tokens"] = max_tokens

        # Add remaining kwargs
        call_kwargs.update(kwargs)

        return self.openai_client.chat.completions.create(**call_kwargs)

    def _call_gemini(
        self,
        model: str,
        messages: List[Dict[str, Any]],
        temperature: float,
        response_format: Optional[Dict[str, str]],
        max_tokens: Optional[int],
        **kwargs
    ) -> ChatCompletion:
        """
        Call Google Gemini API.

        Supports both text and vision (image) content.
        Images should be in OpenAI format (image_url with base64 data URL).
        """
        if not self.gemini_api_key:
            raise ValueError("GEMINI_API_KEY not configured")

        # Get the actual Gemini model name
        gemini_model = self.GEMINI_MODEL_NAMES.get(model, "gemini-exp-1206")

        # Convert messages to Gemini format
        system_prompt = ""
        user_messages = []

        for msg in messages:
            if msg["role"] == "system":
                system_prompt = msg["content"] if isinstance(msg["content"], str) else str(msg["content"])
            elif msg["role"] == "user":
                parts = self._convert_content_to_gemini_parts(msg["content"])
                user_messages.append({"role": "user", "parts": parts})
            elif msg["role"] == "assistant":
                content = msg["content"]
                if isinstance(content, str):
                    user_messages.append({"role": "model", "parts": [{"text": content}]})
                else:
                    parts = self._convert_content_to_gemini_parts(content)
                    user_messages.append({"role": "model", "parts": parts})

        # Build Gemini API request
        url = (
            f"https://generativelanguage.googleapis.com/v1beta/models/"
            f"{gemini_model}:generateContent?key={self.gemini_api_key}"
        )

        payload = {
            "contents": user_messages,
            "generationConfig": {
                "temperature": temperature,
                "maxOutputTokens": max_tokens or 2048,
            },
        }

        # Add system instruction if present
        if system_prompt:
            payload["system_instruction"] = {"parts": [{"text": system_prompt}]}

        # Handle JSON response format
        if response_format and response_format.get("type") == "json_object":
            payload["generationConfig"]["response_mime_type"] = "application/json"

        # Retry logic for rate limits (429 errors)
        for attempt in range(4):  # 1 try + up to 3 retries
            try:
                resp = requests.post(url, json=payload, timeout=90)

                if resp.status_code == 429:
                    # Exponential backoff: 1s, 2s, 4s
                    if attempt < 3:
                        time.sleep(2 ** attempt)
                        continue

                if not resp.ok:
                    try:
                        err = resp.json()
                    except Exception:
                        err = resp.text
                    raise RuntimeError(f"Gemini API error {resp.status_code}: {err}")

                # Parse response
                data = resp.json()
                candidate = (data.get("candidates") or [{}])[0]
                parts = candidate.get("content", {}).get("parts", [])
                response_text = "".join(p.get("text", "") for p in parts).strip()

                # Return in OpenAI-compatible format
                return ChatCompletion(
                    choices=[
                        ChatChoice(
                            message=ChatMessage(
                                role="assistant",
                                content=response_text
                            )
                        )
                    ]
                )

            except requests.exceptions.Timeout:
                if attempt < 3:
                    time.sleep(2 ** attempt)
                    continue
                raise RuntimeError("Gemini API request timed out after multiple retries")
            except requests.exceptions.RequestException as e:
                if attempt < 3:
                    time.sleep(2 ** attempt)
                    continue
                raise RuntimeError(f"Gemini API request failed: {str(e)}")

        raise RuntimeError("Gemini API request failed after all retries")

    def _convert_content_to_gemini_parts(self, content: Union[str, List[Dict[str, Any]]]) -> List[Dict[str, Any]]:
        """
        Convert OpenAI-style content to Gemini parts format.

        Handles:
        - Simple string content
        - Complex content with text and image_url parts

        Args:
            content: Either a string or list of content parts

        Returns:
            List of Gemini-format parts
        """
        if isinstance(content, str):
            return [{"text": content}]

        parts = []
        for item in content:
            if isinstance(item, str):
                parts.append({"text": item})
            elif isinstance(item, dict):
                item_type = item.get("type", "")

                if item_type == "text":
                    parts.append({"text": item.get("text", "")})

                elif item_type == "image_url":
                    # Convert OpenAI image_url format to Gemini inline_data format
                    image_url_data = item.get("image_url", {})
                    url = image_url_data.get("url", "") if isinstance(image_url_data, dict) else str(image_url_data)

                    if url.startswith("data:"):
                        # Parse data URL: data:image/png;base64,<data>
                        try:
                            # Extract mime type and base64 data
                            header, b64_data = url.split(",", 1)
                            # header format: data:image/png;base64
                            mime_type = header.split(":")[1].split(";")[0]

                            parts.append({
                                "inline_data": {
                                    "mime_type": mime_type,
                                    "data": b64_data
                                }
                            })
                        except (ValueError, IndexError) as e:
                            print(f"[Gemini] Failed to parse image data URL: {e}")
                            continue
                    else:
                        # External URL - Gemini doesn't support external URLs directly
                        # We'd need to fetch and convert, for now skip with warning
                        print(f"[Gemini] External image URLs not supported, skipping: {url[:50]}...")
                        continue

                elif item_type == "input_image":
                    # Handle Responses API format (input_image)
                    url = item.get("image_url", "")
                    if url.startswith("data:"):
                        try:
                            header, b64_data = url.split(",", 1)
                            mime_type = header.split(":")[1].split(";")[0]
                            parts.append({
                                "inline_data": {
                                    "mime_type": mime_type,
                                    "data": b64_data
                                }
                            })
                        except (ValueError, IndexError) as e:
                            print(f"[Gemini] Failed to parse input_image data URL: {e}")
                            continue

                elif item_type == "input_text":
                    # Handle Responses API format (input_text)
                    parts.append({"text": item.get("text", "")})

        return parts if parts else [{"text": ""}]


def create_unified_client(openai_client=None, gemini_api_key: Optional[str] = None) -> UnifiedLLMClient:
    """
    Create a unified LLM client.

    Args:
        openai_client: OpenAI client instance (optional)
        gemini_api_key: Gemini API key (optional)

    Returns:
        UnifiedLLMClient instance
    """
    return UnifiedLLMClient(openai_client=openai_client, gemini_api_key=gemini_api_key)
