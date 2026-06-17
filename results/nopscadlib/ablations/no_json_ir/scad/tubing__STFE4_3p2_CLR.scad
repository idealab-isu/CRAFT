// PTFE heatshrink sleeving tubing (hollow tube)
// Fixes: ensure visible geometry, smooth cylinder, PTFE-like semi-translucent white

$fa = 3;          // finer angular resolution
$fs = 0.25;       // finer segment length
$fn = 128;        // high radial resolution for smooth cross-section

inner_diameter = 5;   // mm
outer_diameter = 7;   // mm
length = 50;          // mm
centered = true;

// Create a hollow cylindrical tube
module tubing_segment(inner_d, outer_d, len, centered=true) {
    // Robustness: ensure valid wall thickness
    inner_d2 = min(inner_d, outer_d - 0.2);

    difference() {
        cylinder(d=outer_d, h=len, center=centered);
        // Slightly longer inner cut to guarantee clean subtraction
        cylinder(d=inner_d2, h=len + 0.4, center=centered);
    }
}

// PTFE-like appearance (semi-translucent white)
color([0.97, 0.97, 0.98, 0.45])
    tubing_segment(inner_diameter, outer_diameter, length, centered);