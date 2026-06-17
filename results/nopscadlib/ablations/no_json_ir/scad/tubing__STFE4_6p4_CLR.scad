// PTFE heatshrink sleeving tubing (hollow tube)

// Quality (smooth circle)
$fn = 128;

// Parameters (mm)
inner_diameter = 5;
outer_diameter = 7;
length = 50;
centered = true;

// Robust hollow tube
module tubing_segment(inner_d, outer_d, len, centered=false) {
    wall = (outer_d - inner_d) / 2;
    assert(inner_d > 0, "inner_d must be > 0");
    assert(outer_d > inner_d, "outer_d must be > inner_d");
    assert(wall > 0, "wall thickness must be > 0");
    assert(len > 0, "length must be > 0");

    eps = 0.02; // small overlap to avoid coplanar faces

    difference() {
        cylinder(d=outer_d, h=len, center=centered);
        // Inner bore: always centered, and slightly longer to guarantee a clean through-hole
        cylinder(d=inner_d, h=len + 2*eps, center=true);
    }
}

tubing_segment(inner_diameter, outer_diameter, length, centered);