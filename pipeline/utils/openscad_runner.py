"""
CRAFT OpenSCAD Runner

Wrapper for executing OpenSCAD to render .scad files to images.
"""

import os
import subprocess
from enum import Enum, auto
from typing import Optional, Tuple


class RenderMode(Enum):
    """OpenSCAD render modes."""
    preview = auto()    # Fast preview (F5 in GUI)
    render = auto()     # Full render (F6 in GUI)


class OpenScadRunner:
    """
    Runs OpenSCAD to render .scad files to images.
    
    Usage:
        runner = OpenScadRunner("model.scad", "output.png")
        runner.run()
        if runner.good():
            print("Render successful!")
    """
    
    def __init__(
        self,
        scad_path: str,
        output_path: str,
        render_mode: RenderMode = RenderMode.preview,
        imgsize: Tuple[int, int] = (800, 600),
        camera: Optional[str] = None,
        colorscheme: str = "Tomorrow",
        timeout: int = 60
    ):
        """
        Initialize the runner.
        
        Args:
            scad_path: Path to input .scad file
            output_path: Path for output image
            render_mode: Preview or full render
            imgsize: Output image size (width, height)
            camera: Optional camera parameters
            colorscheme: OpenSCAD color scheme
            timeout: Render timeout in seconds
        """
        self.scad_path = scad_path
        self.output_path = output_path
        self.render_mode = render_mode
        self.imgsize = imgsize
        self.camera = camera
        self.colorscheme = colorscheme
        self.timeout = timeout
        
        self.returncode: Optional[int] = None
        self.stdout: str = ""
        self.stderr: str = ""
        self._success: bool = False
    
    def run(self) -> bool:
        """
        Execute OpenSCAD render.
        
        Returns:
            True if render succeeded
        """
        # Build command
        cmd = ["openscad"]
        
        # Output file
        cmd.extend(["-o", self.output_path])
        
        # Image size
        cmd.append(f"--imgsize={self.imgsize[0]},{self.imgsize[1]}")
        
        # Render mode
        if self.render_mode == RenderMode.preview:
            cmd.append("--preview")
        # Full render is default
        
        # Color scheme
        cmd.extend(["--colorscheme", self.colorscheme])
        
        # Camera (auto-center if not specified)
        if self.camera:
            cmd.extend(["--camera", self.camera])
        else:
            cmd.append("--autocenter")
            cmd.append("--viewall")
        
        # Input file
        cmd.append(self.scad_path)
        
        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=self.timeout
            )
            
            self.returncode = result.returncode
            self.stdout = result.stdout
            self.stderr = result.stderr
            
            # Check if output file was created
            self._success = (
                result.returncode == 0 and
                os.path.exists(self.output_path) and
                os.path.getsize(self.output_path) > 0
            )
            
            return self._success
            
        except subprocess.TimeoutExpired:
            self.stderr = f"Render timed out after {self.timeout} seconds"
            self._success = False
            return False
            
        except FileNotFoundError:
            self.stderr = "OpenSCAD not found. Please install OpenSCAD."
            self._success = False
            return False
            
        except Exception as e:
            self.stderr = f"Render error: {str(e)}"
            self._success = False
            return False
    
    def good(self) -> bool:
        """Check if render was successful."""
        return self._success
    
    def get_errors(self) -> str:
        """Get error messages from render."""
        errors = []
        
        if self.stderr:
            # Extract error lines
            for line in self.stderr.split('\n'):
                if 'ERROR' in line or 'error' in line.lower():
                    errors.append(line.strip())
        
        if not errors and not self._success:
            errors.append("Render failed (unknown reason)")
        
        return "; ".join(errors)


def render_scad(
    scad_path: str,
    output_path: str,
    render_mode: RenderMode = RenderMode.preview,
    imgsize: Tuple[int, int] = (800, 600)
) -> bool:
    """
    Convenience function to render a .scad file.
    
    Args:
        scad_path: Path to .scad file
        output_path: Path for output image
        render_mode: Preview or full render
        imgsize: Output image size
        
    Returns:
        True if successful
    """
    runner = OpenScadRunner(scad_path, output_path, render_mode, imgsize)
    return runner.run()


def render_scad_code(
    code: str,
    output_path: str,
    render_mode: RenderMode = RenderMode.preview,
    imgsize: Tuple[int, int] = (800, 600),
    temp_dir: str = "/tmp"
) -> Tuple[bool, str]:
    """
    Render OpenSCAD code directly.

    Args:
        code: OpenSCAD code string
        output_path: Path for output image
        render_mode: Preview or full render
        imgsize: Output image size
        temp_dir: Directory for temporary .scad file

    Returns:
        Tuple of (success, scad_path)
    """
    import tempfile

    # Write code to temp file
    with tempfile.NamedTemporaryFile(
        mode='w',
        suffix='.scad',
        dir=temp_dir,
        delete=False
    ) as f:
        f.write(code)
        scad_path = f.name

    runner = OpenScadRunner(scad_path, output_path, render_mode, imgsize)
    success = runner.run()

    return success, scad_path


def export_stl(
    scad_path: str,
    output_path: str,
    timeout: int = 300
) -> Tuple[bool, str]:
    """
    Export OpenSCAD file to STL format.

    Args:
        scad_path: Path to input .scad file
        output_path: Path for output .stl file
        timeout: Export timeout in seconds

    Returns:
        Tuple of (success, error_message)
    """
    cmd = ["openscad", "-o", output_path, scad_path]

    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=timeout
        )

        # Check if output file was created
        success = (
            result.returncode == 0 and
            os.path.exists(output_path) and
            os.path.getsize(output_path) > 0
        )

        if success:
            return True, ""
        else:
            error_msg = result.stderr or "STL export failed (unknown reason)"
            return False, error_msg

    except subprocess.TimeoutExpired:
        return False, f"STL export timed out after {timeout} seconds"

    except FileNotFoundError:
        return False, "OpenSCAD not found. Please install OpenSCAD."

    except Exception as e:
        return False, f"STL export error: {str(e)}"


def export_stl_from_code(
    code: str,
    output_path: str,
    timeout: int = 300,
    temp_dir: str = "/tmp"
) -> Tuple[bool, str]:
    """
    Export OpenSCAD code directly to STL format.

    Args:
        code: OpenSCAD code string
        output_path: Path for output .stl file
        timeout: Export timeout in seconds
        temp_dir: Directory for temporary .scad file

    Returns:
        Tuple of (success, error_message)
    """
    import tempfile

    # Write code to temp file
    with tempfile.NamedTemporaryFile(
        mode='w',
        suffix='.scad',
        dir=temp_dir,
        delete=False
    ) as f:
        f.write(code)
        scad_path = f.name

    success, error = export_stl(scad_path, output_path, timeout)

    # Clean up temp file
    try:
        os.remove(scad_path)
    except:
        pass

    return success, error
