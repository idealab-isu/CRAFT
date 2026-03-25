"""
NopSCADlib Knowledge Base Configuration

Central configuration for the RAG system including paths, thresholds,
and model settings.
"""

import os
from pathlib import Path
from dataclasses import dataclass, field
from typing import List, Dict, Optional

# Base paths
CRAFT_DIR = Path(__file__).parent.parent
KB_DIR = CRAFT_DIR / "kb"
KB_DATA_DIR = CRAFT_DIR / "kb_data"
DOCUMENTATION_PATH = KB_DATA_DIR / "documentation.json"

# NopSCADlib paths
NOPSCADLIB_DIR = KB_DATA_DIR / "nopscadlib"
NOPSCADLIB_REPO = "https://github.com/nophead/NopSCADlib.git"

# Storage paths
CHROMA_DB_DIR = KB_DATA_DIR / "chroma_db"
REFERENCE_IMAGES_DIR = KB_DATA_DIR / "reference_images"
COMPONENT_INDEX_PATH = KB_DATA_DIR / "component_index.json"

# Ensure directories exist
for dir_path in [KB_DATA_DIR, CHROMA_DB_DIR, REFERENCE_IMAGES_DIR]:
    dir_path.mkdir(parents=True, exist_ok=True)


@dataclass
class VerificationThresholds:
    """Thresholds for visual verification against KB references."""
    ssim_min: float = 0.88          # Structural similarity minimum
    iou_min: float = 0.85           # Silhouette IoU minimum
    perceptual_max: float = 0.15    # Max perceptual distance (lower = more similar)

    # Combined pass requires both SSIM and IoU to pass
    require_both: bool = True


@dataclass
class KBConfig:
    """Main Knowledge Base configuration."""

    # Paths
    nopscadlib_dir: Path = NOPSCADLIB_DIR
    chroma_db_dir: Path = CHROMA_DB_DIR
    reference_images_dir: Path = REFERENCE_IMAGES_DIR
    component_index_path: Path = COMPONENT_INDEX_PATH

    # NopSCADlib categories to index
    categories: List[str] = field(default_factory=lambda: [
        "vitamins",      # Real components: motors, bearings, electronics
        "printed",       # 3D printed parts
        # "assemblies",  # Complete assemblies (optional, more complex)
    ])

    # Reference image rendering
    render_views: List[str] = field(default_factory=lambda: [
        "front",    # Y- view
        "top",      # Z+ view
        "iso1",     # Front-right-top isometric
        "iso2",     # Back-left-top isometric
    ])
    render_size: tuple = (512, 512)

    # Embedding settings
    text_embedding_model: str = "text-embedding-3-small"
    use_clip_embeddings: bool = True  # For vision-based retrieval

    # ChromaDB collection name
    collection_name: str = "nopscadlib_components"

    # Detection settings
    # Threshold 0.7 requires multiple keyword matches or exact/alias match
    # Single keyword matches (0.6) won't trigger false positives like "ball" -> "ball bearing"
    detection_confidence_threshold: float = 0.7
    max_components_per_query: int = 5

    # Verification
    verification: VerificationThresholds = field(default_factory=VerificationThresholds)
    max_repair_attempts: int = 3

    # Retrieval settings
    retrieval_top_k: int = 3
    hybrid_alpha: float = 0.7  # Weight for text vs vision (0.7 = 70% text, 30% vision)


# Global config instance
KB_CONFIG = KBConfig()


# Component category mappings for better detection
CATEGORY_KEYWORDS = {
    "motors": ["motor", "stepper", "servo", "nema", "dc motor", "bldc"],
    "bearings": ["bearing", "ball bearing", "linear bearing", "lm8uu", "608", "625"],
    "electronics": ["arduino", "raspberry", "pi", "esp32", "esp8266", "pcb", "led"],
    "fasteners": ["screw", "bolt", "nut", "washer", "m3", "m4", "m5", "m6", "m8"],
    "belts": ["belt", "gt2", "timing belt", "pulley"],
    "rails": ["rail", "linear rail", "mgn", "extrusion", "v-slot", "2020", "2040"],
    "connectors": ["connector", "jst", "dupont", "terminal", "wire"],
    "fans": ["fan", "blower", "cooling", "40mm fan", "30mm fan"],
    "displays": ["display", "lcd", "oled", "screen"],
    "switches": ["switch", "button", "microswitch", "limit switch"],
    "power": ["psu", "power supply", "buck", "boost", "voltage regulator"],
    "pneumatics": ["pneumatic", "solenoid", "valve", "cylinder"],
    "optics": ["lens", "mirror", "led", "light"],
    "springs": ["spring", "compression spring", "tension spring"],
    "gears": ["gear", "pinion", "rack", "worm gear"],
    "shafts": ["shaft", "rod", "leadscrew", "threaded rod", "smooth rod"],
    "couplers": ["coupler", "coupling", "flexible coupler", "rigid coupler"],
    "pulleys": ["pulley", "idler", "gt2 pulley", "timing pulley"],
    "nuts": ["t-nut", "hammer nut", "drop-in nut", "insert"],
    "tubes": ["tube", "tubing", "ptfe", "bowden"],
}

# Specific component name mappings (for exact matches)
COMPONENT_ALIASES = {
    # Servos
    "sg90": ["sg90", "micro servo", "9g servo"],
    "mg90s": ["mg90s", "metal gear servo"],
    "mg996r": ["mg996r", "standard servo"],

    # Steppers
    "nema17": ["nema17", "nema 17", "42mm stepper"],
    "nema14": ["nema14", "nema 14", "35mm stepper"],
    "nema23": ["nema23", "nema 23", "57mm stepper"],

    # Bearings
    "608": ["608", "608zz", "skateboard bearing"],
    "625": ["625", "625zz"],
    "lm8uu": ["lm8uu", "lm8", "8mm linear bearing"],
    "lm10uu": ["lm10uu", "lm10", "10mm linear bearing"],

    # Electronics
    "arduino_uno": ["arduino uno", "uno"],
    "arduino_nano": ["arduino nano", "nano"],
    "raspberry_pi": ["raspberry pi", "rpi", "raspi"],
    "esp32": ["esp32", "esp-32"],

    # Linear motion
    "mgn12": ["mgn12", "mgn12h", "12mm linear rail"],
    "mgn15": ["mgn15", "mgn15h", "15mm linear rail"],

    # Belts
    "gt2_belt": ["gt2", "gt2 belt", "2mm pitch belt"],
    "gt2_pulley": ["gt2 pulley", "timing pulley"],
}


def get_config() -> KBConfig:
    """Get the global KB configuration."""
    return KB_CONFIG


def update_config(**kwargs) -> KBConfig:
    """Update configuration values."""
    global KB_CONFIG
    for key, value in kwargs.items():
        if hasattr(KB_CONFIG, key):
            setattr(KB_CONFIG, key, value)
    return KB_CONFIG
