// Symmetric cross-shaped hub: cylindrical core + 4 rectangular lugs
// No holes/cutouts. One connected solid. Bounding box: 11.68 x 11.68 x 6.35 mm.

$fn = 96;

// Parameters (mm)
bbox_x = 11.68;
bbox_y = 11.68;
bbox_z = 6.35;

core_d = 7.20;          // cylindrical core diameter
core_h = bbox_z;        // overall height

lug_w = 3.20;           // lug width (tangential)
lug_h = bbox_z;         // lug height (same as core)
overlap = 0.20;         // small overlap to guarantee connectivity

// Derived: lug radial length so overall bbox matches
lug_len_radial = (bbox_x - core_d) / 2;   // protrusion beyond core radius

// Fillet disabled by default to keep simple solid (set >0 if desired)
edge_round_r = 0.0;
draft_scale_xy = 1.0;

// Base shapes
module central_core() {
    cylinder(r = core_d/2, h = core_h, center = true);
}

module lug_at_angle(a_deg) {
    // Lug extends outward from the core sidewall; overlaps slightly into core
    rotate([0, 0, a_deg])
        translate([core_d/2 + lug_len_radial/2 - overlap, 0, 0])
            cube([lug_len_radial + 2*overlap, lug_w, lug_h], center = true);
}

module core_with_lugs() {
    union() {
        central_core();
        for (a = [0, 90, 180, 270]) lug_at_angle(a);
    }
}

module edge_fillet_optional() {
    if (edge_round_r > 0) {
        minkowski() {
            core_with_lugs();
            sphere(r = edge_round_r);
        }
    } else {
        core_with_lugs();
    }
}

// Final output
scale([draft_scale_xy, draft_scale_xy, 1])
    edge_fillet_optional();