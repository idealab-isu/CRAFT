"""
GenCAD Dataset Loader

Loads the GenCAD-Code dataset from parquet files.
"""

from __future__ import annotations

import io
from pathlib import Path
from typing import Iterator, Optional, Dict, Any, List, TYPE_CHECKING
from dataclasses import dataclass

if TYPE_CHECKING:
    import pandas as pd

try:
    import pandas as pd
    HAS_PANDAS = True
except ImportError:
    pd = None  # type: ignore
    HAS_PANDAS = False

try:
    from PIL import Image
    HAS_PIL = True
except ImportError:
    HAS_PIL = False


@dataclass
class Sample:
    """A single sample from the GenCAD dataset."""
    index: int
    deepcad_id: str
    cadquery_code: str
    image: Any  # PIL Image or None
    token_count: int
    split: str  # "train", "test", or "validation"

    def __repr__(self):
        return f"Sample(idx={self.index}, id={self.deepcad_id}, tokens={self.token_count})"


class GenCADLoader:
    """
    Loader for GenCAD-Code dataset.

    The dataset is stored in parquet files with the following structure:
    - data/train-*.parquet
    - data/test-*.parquet
    - data/validation-*.parquet

    Each row contains:
    - image: PIL Image (448x448)
    - cadquery: CadQuery Python code string
    - deepcad_id: unique identifier
    - token_count: number of tokens in code
    - prompt: instruction text (not used)
    - hundred_subset: boolean flag (not used)
    """

    def __init__(self, dataset_path: str):
        """
        Initialize the loader.

        Args:
            dataset_path: Path to the data directory containing parquet files
        """
        if not HAS_PANDAS:
            raise ImportError("pandas is required. Install with: pip install pandas pyarrow")

        self.dataset_path = Path(dataset_path)
        self._validate_path()

        # Cache for loaded dataframes
        self._cache: Dict[str, pd.DataFrame] = {}

    def _validate_path(self):
        """Validate that the dataset path exists and has parquet files."""
        if not self.dataset_path.exists():
            raise FileNotFoundError(f"Dataset path not found: {self.dataset_path}")

        parquet_files = list(self.dataset_path.glob("*.parquet"))
        if not parquet_files:
            raise FileNotFoundError(f"No parquet files found in: {self.dataset_path}")

    def _get_parquet_files(self, split: str) -> List[Path]:
        """Get parquet files for a specific split."""
        pattern = f"{split}-*.parquet"
        files = sorted(self.dataset_path.glob(pattern))
        return files

    def _load_split(self, split: str) -> pd.DataFrame:
        """Load all parquet files for a split into a single DataFrame."""
        if split in self._cache:
            return self._cache[split]

        files = self._get_parquet_files(split)
        if not files:
            raise FileNotFoundError(f"No {split} parquet files found")

        dfs = []
        for f in files:
            df = pd.read_parquet(f)
            dfs.append(df)

        combined = pd.concat(dfs, ignore_index=True)
        self._cache[split] = combined
        return combined

    def _row_to_sample(self, row: pd.Series, index: int, split: str) -> Sample:
        """Convert a DataFrame row to a Sample object."""
        # Extract image
        image = None
        if HAS_PIL and "image" in row:
            img_data = row["image"]
            if img_data is not None:
                # Handle different image formats from parquet
                if isinstance(img_data, dict) and "bytes" in img_data:
                    image = Image.open(io.BytesIO(img_data["bytes"]))
                elif isinstance(img_data, bytes):
                    image = Image.open(io.BytesIO(img_data))
                elif hasattr(img_data, "tobytes"):
                    # PIL Image already
                    image = img_data

        # Extract code - handle both 'cadquery' and 'code' column names
        cadquery_code = ""
        if "cadquery" in row:
            cadquery_code = row["cadquery"]
        elif "code" in row:
            cadquery_code = row["code"]

        return Sample(
            index=index,
            deepcad_id=row.get("deepcad_id", f"unknown_{index}"),
            cadquery_code=cadquery_code,
            image=image,
            token_count=row.get("token_count", 0),
            split=split,
        )

    def load_samples(
        self,
        split: str = "train",
        n: Optional[int] = None,
        offset: int = 0
    ) -> List[Sample]:
        """
        Load samples from the dataset.

        Args:
            split: Which split to load ("train", "test", "validation")
            n: Number of samples to load (None = all)
            offset: Starting index

        Returns:
            List of Sample objects
        """
        df = self._load_split(split)

        # Apply offset and limit
        end_idx = len(df) if n is None else min(offset + n, len(df))
        subset = df.iloc[offset:end_idx]

        samples = []
        for i, (idx, row) in enumerate(subset.iterrows()):
            sample = self._row_to_sample(row, offset + i, split)
            samples.append(sample)

        return samples

    def iter_samples(
        self,
        split: str = "train",
        n: Optional[int] = None,
        offset: int = 0
    ) -> Iterator[Sample]:
        """
        Iterate over samples (memory-efficient for large datasets).

        Args:
            split: Which split to load
            n: Number of samples (None = all)
            offset: Starting index

        Yields:
            Sample objects one at a time
        """
        df = self._load_split(split)

        end_idx = len(df) if n is None else min(offset + n, len(df))

        for i in range(offset, end_idx):
            row = df.iloc[i]
            yield self._row_to_sample(row, i, split)

    def get_split_size(self, split: str) -> int:
        """Get the number of samples in a split."""
        df = self._load_split(split)
        return len(df)

    def get_sample(self, split: str, index: int) -> Sample:
        """Get a specific sample by index."""
        df = self._load_split(split)
        if index < 0 or index >= len(df):
            raise IndexError(f"Index {index} out of range for {split} split (size={len(df)})")

        row = df.iloc[index]
        return self._row_to_sample(row, index, split)

    def info(self) -> Dict[str, Any]:
        """Get dataset information."""
        info = {
            "path": str(self.dataset_path),
            "splits": {},
        }

        for split in ["train", "test", "validation"]:
            files = self._get_parquet_files(split)
            if files:
                try:
                    df = self._load_split(split)
                    info["splits"][split] = {
                        "files": len(files),
                        "samples": len(df),
                        "columns": list(df.columns),
                    }
                except Exception as e:
                    info["splits"][split] = {"error": str(e)}

        return info
