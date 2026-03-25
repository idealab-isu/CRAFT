"""
NopSCADlib Indexer

Parses the NopSCADlib repository to extract component information:
- Module definitions and source code
- Parameters and their defaults
- Documentation and comments
- Dependencies (includes)
"""

import os
import re
import json
import subprocess
from pathlib import Path
from dataclasses import dataclass, field, asdict
from typing import List, Dict, Optional, Tuple, Set
from datetime import datetime

from .config import (
    KB_CONFIG, NOPSCADLIB_DIR, NOPSCADLIB_REPO,
    COMPONENT_INDEX_PATH, CATEGORY_KEYWORDS
)


@dataclass
class ComponentParameter:
    """A parameter for a component module."""
    name: str
    default_value: Optional[str] = None
    description: Optional[str] = None
    param_type: str = "unknown"  # number, string, boolean, array


@dataclass
class ComponentInfo:
    """Complete information about a NopSCADlib component."""
    # Identification
    id: str                          # Unique identifier (e.g., "vitamins_servo_sg90")
    name: str                        # Display name (e.g., "SG90 Servo")
    module_name: str                 # OpenSCAD module name (e.g., "SG90")

    # Classification
    category: str                    # vitamins, printed, assemblies
    subcategory: str                 # e.g., servos, bearings, motors

    # Source code
    source_file: str                 # Relative path to .scad file
    source_code: str                 # Full module source code
    module_code: str                 # Just the module definition

    # Documentation
    description: str = ""
    comments: str = ""

    # Parameters
    parameters: List[ComponentParameter] = field(default_factory=list)

    # Dependencies
    includes: List[str] = field(default_factory=list)
    uses: List[str] = field(default_factory=list)
    dependencies: List[str] = field(default_factory=list)  # Other modules called

    # Metadata
    file_path: str = ""              # Absolute path
    line_number: int = 0             # Line where module starts
    indexed_at: str = ""             # Timestamp

    # Search helpers
    keywords: List[str] = field(default_factory=list)
    aliases: List[str] = field(default_factory=list)

    def to_dict(self) -> dict:
        """Convert to dictionary for JSON serialization."""
        return asdict(self)

    @classmethod
    def from_dict(cls, data: dict) -> 'ComponentInfo':
        """Create from dictionary."""
        # Handle nested dataclasses
        if 'parameters' in data:
            data['parameters'] = [
                ComponentParameter(**p) if isinstance(p, dict) else p
                for p in data['parameters']
            ]
        return cls(**data)


class NopSCADlibIndexer:
    """
    Indexes the NopSCADlib repository to extract component information.
    """

    def __init__(self, nopscadlib_dir: Path = None):
        self.nopscadlib_dir = nopscadlib_dir or NOPSCADLIB_DIR
        self.components: Dict[str, ComponentInfo] = {}

        # Regex patterns for parsing OpenSCAD
        self.module_pattern = re.compile(
            r'^module\s+(\w+)\s*\(([^)]*)\)\s*\{',
            re.MULTILINE
        )
        self.function_pattern = re.compile(
            r'^function\s+(\w+)\s*\(([^)]*)\)\s*=',
            re.MULTILINE
        )
        self.include_pattern = re.compile(
            r'^(?:include|use)\s*<([^>]+)>',
            re.MULTILINE
        )
        self.comment_pattern = re.compile(
            r'//[^\n]*|/\*[\s\S]*?\*/',
            re.MULTILINE
        )

    def clone_or_update_repo(self) -> bool:
        """Clone NopSCADlib repo or update if exists."""
        if self.nopscadlib_dir.exists():
            print(f"NopSCADlib already exists at {self.nopscadlib_dir}")
            # Try to update
            try:
                subprocess.run(
                    ["git", "pull"],
                    cwd=self.nopscadlib_dir,
                    check=True,
                    capture_output=True
                )
                print("Updated NopSCADlib to latest version")
            except subprocess.CalledProcessError:
                print("Could not update, using existing version")
            return True

        print(f"Cloning NopSCADlib to {self.nopscadlib_dir}...")
        try:
            subprocess.run(
                ["git", "clone", "--depth", "1", NOPSCADLIB_REPO, str(self.nopscadlib_dir)],
                check=True,
                capture_output=True
            )
            print("Successfully cloned NopSCADlib")
            return True
        except subprocess.CalledProcessError as e:
            print(f"Failed to clone NopSCADlib: {e}")
            return False

    def find_scad_files(self, category: str) -> List[Path]:
        """Find all .scad files in a category directory."""
        category_dir = self.nopscadlib_dir / category
        if not category_dir.exists():
            print(f"Category directory not found: {category_dir}")
            return []

        scad_files = []
        for scad_file in category_dir.rglob("*.scad"):
            # Skip test files and certain patterns
            if any(skip in scad_file.name.lower() for skip in ['test', '_test', 'tests']):
                continue
            scad_files.append(scad_file)

        return sorted(scad_files)

    def extract_module_code(self, content: str, module_name: str, start_pos: int) -> Tuple[str, int]:
        """Extract the complete module code including nested braces."""
        # Find the opening brace
        brace_start = content.find('{', start_pos)
        if brace_start == -1:
            return "", 0

        # Count braces to find matching close
        depth = 1
        pos = brace_start + 1
        while pos < len(content) and depth > 0:
            char = content[pos]
            if char == '{':
                depth += 1
            elif char == '}':
                depth -= 1
            pos += 1

        # Extract the full module
        module_start = content.rfind('module', 0, brace_start)
        module_code = content[module_start:pos]

        return module_code, pos - module_start

    def parse_parameters(self, param_str: str) -> List[ComponentParameter]:
        """Parse module parameters from the parameter string."""
        params = []
        if not param_str.strip():
            return params

        # Split by comma, but respect nested structures
        current = ""
        depth = 0
        parts = []

        for char in param_str:
            if char in '([{':
                depth += 1
            elif char in ')]}':
                depth -= 1
            elif char == ',' and depth == 0:
                parts.append(current.strip())
                current = ""
                continue
            current += char

        if current.strip():
            parts.append(current.strip())

        # Parse each parameter
        for part in parts:
            part = part.strip()
            if not part:
                continue

            # Check for default value
            if '=' in part:
                name_part, default = part.split('=', 1)
                name = name_part.strip()
                default_value = default.strip()
            else:
                name = part
                default_value = None

            # Determine type from default value
            param_type = "unknown"
            if default_value:
                if default_value.lower() in ('true', 'false'):
                    param_type = "boolean"
                elif default_value.startswith('"') or default_value.startswith("'"):
                    param_type = "string"
                elif default_value.startswith('['):
                    param_type = "array"
                elif re.match(r'^-?\d+\.?\d*$', default_value):
                    param_type = "number"

            params.append(ComponentParameter(
                name=name,
                default_value=default_value,
                param_type=param_type
            ))

        return params

    def extract_description(self, content: str, module_start: int) -> str:
        """Extract description from comments before the module."""
        # Look for comments in the 500 chars before module
        search_start = max(0, module_start - 500)
        before_module = content[search_start:module_start]

        # Find block comments
        block_comments = re.findall(r'/\*\s*([\s\S]*?)\s*\*/', before_module)
        if block_comments:
            return block_comments[-1].strip()

        # Find line comments
        lines = before_module.split('\n')
        comment_lines = []
        for line in reversed(lines):
            stripped = line.strip()
            if stripped.startswith('//'):
                comment_lines.insert(0, stripped[2:].strip())
            elif stripped and not stripped.startswith('//'):
                break

        if comment_lines:
            return ' '.join(comment_lines)

        return ""

    def extract_includes(self, content: str) -> Tuple[List[str], List[str]]:
        """Extract include and use statements."""
        includes = []
        uses = []

        for match in re.finditer(r'^(include|use)\s*<([^>]+)>', content, re.MULTILINE):
            statement_type = match.group(1)
            path = match.group(2)
            if statement_type == 'include':
                includes.append(path)
            else:
                uses.append(path)

        return includes, uses

    def generate_keywords(self, component: ComponentInfo) -> List[str]:
        """Generate search keywords for a component."""
        keywords = set()

        # Add name variants
        keywords.add(component.name.lower())
        keywords.add(component.module_name.lower())

        # Split camelCase and snake_case
        name_parts = re.split(r'[_\s]+|(?<=[a-z])(?=[A-Z])', component.name)
        keywords.update(p.lower() for p in name_parts if len(p) > 2)

        # Add from description
        if component.description:
            words = re.findall(r'\b\w{3,}\b', component.description.lower())
            keywords.update(words[:10])  # Limit

        # Add category keywords
        keywords.add(component.category)
        keywords.add(component.subcategory)

        # Add parameter names (might be descriptive)
        for param in component.parameters:
            if len(param.name) > 2 and not param.name.startswith('_'):
                keywords.add(param.name.lower())

        return list(keywords)

    def parse_scad_file(self, scad_path: Path, category: str) -> List[ComponentInfo]:
        """Parse a .scad file and extract all component modules."""
        components = []

        try:
            content = scad_path.read_text(encoding='utf-8', errors='ignore')
        except Exception as e:
            print(f"Error reading {scad_path}: {e}")
            return components

        # Get subcategory from path
        rel_path = scad_path.relative_to(self.nopscadlib_dir / category)
        if len(rel_path.parts) > 1:
            subcategory = rel_path.parts[0]
        else:
            subcategory = scad_path.stem

        # Extract includes/uses
        includes, uses = self.extract_includes(content)

        # Find all module definitions
        for match in self.module_pattern.finditer(content):
            module_name = match.group(1)
            param_str = match.group(2)
            start_pos = match.start()

            # Skip internal/helper modules (starting with _)
            if module_name.startswith('_'):
                continue

            # Extract module code
            module_code, code_length = self.extract_module_code(
                content, module_name, match.end() - 1
            )
            if not module_code:
                continue

            # Parse parameters
            parameters = self.parse_parameters(param_str)

            # Extract description
            description = self.extract_description(content, start_pos)

            # Create component ID
            component_id = f"{category}_{subcategory}_{module_name}".lower()
            component_id = re.sub(r'[^a-z0-9_]', '_', component_id)

            # Create component info
            component = ComponentInfo(
                id=component_id,
                name=module_name.replace('_', ' ').title(),
                module_name=module_name,
                category=category,
                subcategory=subcategory,
                source_file=str(scad_path.relative_to(self.nopscadlib_dir)),
                source_code=content,
                module_code=module_code,
                description=description,
                parameters=parameters,
                includes=includes,
                uses=uses,
                file_path=str(scad_path),
                line_number=content[:start_pos].count('\n') + 1,
                indexed_at=datetime.now().isoformat()
            )

            # Generate keywords
            component.keywords = self.generate_keywords(component)

            components.append(component)

        return components

    def index_category(self, category: str) -> List[ComponentInfo]:
        """Index all components in a category."""
        print(f"\nIndexing category: {category}")
        scad_files = self.find_scad_files(category)
        print(f"Found {len(scad_files)} .scad files")

        category_components = []
        for scad_file in scad_files:
            components = self.parse_scad_file(scad_file, category)
            category_components.extend(components)
            if components:
                print(f"  {scad_file.name}: {len(components)} modules")

        return category_components

    def index_all(self, categories: List[str] = None) -> Dict[str, ComponentInfo]:
        """Index all categories and return component dictionary."""
        categories = categories or KB_CONFIG.categories

        all_components = {}
        for category in categories:
            components = self.index_category(category)
            for comp in components:
                all_components[comp.id] = comp

        self.components = all_components
        print(f"\nTotal components indexed: {len(all_components)}")
        return all_components

    def save_index(self, output_path: Path = None):
        """Save the component index to JSON."""
        output_path = output_path or COMPONENT_INDEX_PATH

        index_data = {
            "version": "1.0",
            "indexed_at": datetime.now().isoformat(),
            "total_components": len(self.components),
            "categories": list(set(c.category for c in self.components.values())),
            "components": {
                comp_id: comp.to_dict()
                for comp_id, comp in self.components.items()
            }
        }

        output_path.parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, 'w') as f:
            json.dump(index_data, f, indent=2)

        print(f"Index saved to {output_path}")

    def load_index(self, input_path: Path = None) -> Dict[str, ComponentInfo]:
        """Load component index from JSON."""
        input_path = input_path or COMPONENT_INDEX_PATH

        if not input_path.exists():
            print(f"Index file not found: {input_path}")
            return {}

        with open(input_path, 'r') as f:
            index_data = json.load(f)

        self.components = {
            comp_id: ComponentInfo.from_dict(comp_data)
            for comp_id, comp_data in index_data.get('components', {}).items()
        }

        print(f"Loaded {len(self.components)} components from index")
        return self.components

    def get_component(self, component_id: str) -> Optional[ComponentInfo]:
        """Get a specific component by ID."""
        return self.components.get(component_id)

    def search_by_name(self, name: str) -> List[ComponentInfo]:
        """Simple name-based search."""
        name_lower = name.lower()
        results = []

        for comp in self.components.values():
            if (name_lower in comp.name.lower() or
                name_lower in comp.module_name.lower() or
                any(name_lower in kw for kw in comp.keywords)):
                results.append(comp)

        return results

    def get_components_by_category(self, category: str) -> List[ComponentInfo]:
        """Get all components in a category."""
        return [c for c in self.components.values() if c.category == category]

    def get_components_by_subcategory(self, subcategory: str) -> List[ComponentInfo]:
        """Get all components in a subcategory."""
        return [c for c in self.components.values() if c.subcategory == subcategory]

    def get_statistics(self) -> Dict:
        """Get indexing statistics."""
        if not self.components:
            return {"total": 0}

        categories = {}
        subcategories = {}

        for comp in self.components.values():
            categories[comp.category] = categories.get(comp.category, 0) + 1
            subcat_key = f"{comp.category}/{comp.subcategory}"
            subcategories[subcat_key] = subcategories.get(subcat_key, 0) + 1

        return {
            "total": len(self.components),
            "by_category": categories,
            "by_subcategory": subcategories,
            "avg_parameters": sum(
                len(c.parameters) for c in self.components.values()
            ) / len(self.components) if self.components else 0
        }


def index_nopscadlib(categories: List[str] = None, save: bool = True) -> Dict[str, ComponentInfo]:
    """
    Convenience function to index NopSCADlib.

    Args:
        categories: List of categories to index (default: from config)
        save: Whether to save the index to disk

    Returns:
        Dictionary of component ID to ComponentInfo
    """
    indexer = NopSCADlibIndexer()

    # Ensure repo exists
    if not indexer.clone_or_update_repo():
        print("Failed to get NopSCADlib repository")
        return {}

    # Index components
    components = indexer.index_all(categories)

    # Save index
    if save and components:
        indexer.save_index()

    return components


# Module-level cache for component index
_cached_components: Dict[str, ComponentInfo] = {}
_cache_loaded: bool = False


def load_component_index() -> Dict[str, ComponentInfo]:
    """Load the pre-built component index (cached after first load)."""
    global _cached_components, _cache_loaded

    if _cache_loaded:
        return _cached_components

    indexer = NopSCADlibIndexer()
    _cached_components = indexer.load_index()
    _cache_loaded = True
    return _cached_components
