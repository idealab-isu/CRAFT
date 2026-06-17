// 2020 aluminium extrusion (approximate T-slot profile)
// Target: 20mm x 20mm cross-section, 100mm long

$fn = 64;

// Parameters
profile_size     = 20.0;   // mm
length           = 100.0;  // mm (extrusion direction)

bore_d           = 5.0;    // center bore diameter

slot_opening_w   = 6.0;    // slot mouth width at the surface
slot_inner_w     = 10.0;   // wider internal cavity width
slot_depth       = 6.0;    // depth from outer face toward center

edge_chamfer     = 0.8;    // corner chamfer size
overlap          = 0.2;    // small overlap for robust booleans

// --- Helpers ---
module extrusion_main_body() {
    cube([profile_size, profile_size, length], center=true);
}

module central_bore() {
    cylinder(h=length + 2*overlap, r=bore_d/2, center=true);
}

// One face T-slot cut (along +X face), then rotated for 4 sides
module tslot_one_face() {
    // Place cuts so their outer face is slightly outside the profile to guarantee opening
    x_outer = profile_size/2 + overlap;
    x_inner = profile_size/2 - slot_depth;

    // Internal cavity (wider), starts at x_inner and reaches x_outer
    translate([(x_inner + x_outer)/2, 0, 0])
        cube([ (x_outer - x_inner), slot_inner_w, length + 2*overlap ], center=true);

    // Mouth (narrower) near the surface; make it slightly deeper to ensure it connects to cavity
    mouth_depth = slot_depth * 0.55;
    x_mouth_inner = profile_size/2 - mouth_depth;
    translate([(x_mouth_inner + x_outer)/2, 0, 0])
        cube([ (x_outer - x_mouth_inner), slot_opening_w, length + 2*overlap ], center=true);
}

module t_slots_4x() {
    for (a = [0:90:270])
        rotate([0,0,a]) tslot_one_face();
}

// Corner chamfers: subtract small cubes at the four outer corners
module edge_chamfers() {
    // Chamfer cube centered at each corner, pushed slightly outward so it actually removes material
    dx = profile_size/2 - edge_chamfer/2;
    for (sx = [-1, 1], sy = [-1, 1])
        translate([sx*dx, sy*dx, 0])
            cube([edge_chamfer + 2*overlap, edge_chamfer + 2*overlap, length + 2*overlap], center=true);
}

// Final extrusion (single connected solid)
difference() {
    extrusion_main_body();
    central_bore();
    t_slots_4x();
    edge_chamfers();
}