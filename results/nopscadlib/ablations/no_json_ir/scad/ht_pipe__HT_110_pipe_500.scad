// HT 110 pipe 500 mm (hollow) - robust, visible geometry

outer_diameter = 110;     // mm
wall_thickness = 3.2;     // mm
length = 500;             // mm
$fn = 160;

module ht_pipe_segment(od, wt, len) {
    id = od - 2*wt;
    eps = 0.2; // overlap to avoid coplanar faces / rendering artifacts

    // Use non-centered cylinders with explicit Z placement for reliable preview/render
    difference() {
        cylinder(h=len, d=od, center=false);
        translate([0, 0, -eps])
            cylinder(h=len + 2*eps, d=id, center=false);
    }
}

ht_pipe_segment(outer_diameter, wall_thickness, length);