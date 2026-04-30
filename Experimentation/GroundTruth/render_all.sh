#!/usr/bin/env bash
# Render every .scad file in scad/ to stl/ using OpenSCAD in parallel.
set -u

SCAD_DIR="/Users/mohd7/Local/CRAFT/Experimentation/GroundTruth/scad"
STL_DIR="/Users/mohd7/Local/CRAFT/Experimentation/GroundTruth/stl"
LOG_DIR="/Users/mohd7/Local/CRAFT/Experimentation/GroundTruth/render_logs"
mkdir -p "$STL_DIR" "$LOG_DIR"

render_one() {
    local scad="$1"
    local name
    name="$(basename "$scad" .scad)"
    local stl="$STL_DIR/$name.stl"
    local log="$LOG_DIR/$name.log"

    if [[ -s "$stl" ]]; then
        echo "SKIP  $name (exists)"
        return 0
    fi

    if openscad -o "$stl" "$scad" >"$log" 2>&1; then
        echo "OK    $name"
    else
        echo "FAIL  $name (see $log)"
        rm -f "$stl"
        return 1
    fi
}
export -f render_one
export SCAD_DIR STL_DIR LOG_DIR

cd "$SCAD_DIR"
# Use xargs -P for parallelism. 8 jobs is safe on modern macs.
find . -maxdepth 1 -name '*.scad' -print0 \
    | xargs -0 -n 1 -P 8 -I{} bash -c 'render_one "$@"' _ {}
