// 10x10 aluminium extrusion profile, 100mm long (simple T-slot style)
// One connected solid; all feature placement uses formulas from dimensions.

$fn = 64;

// Target dimensions
profile_w = 10.0;
profile_h = 10.0;
length    = 100.0;

// Profile feature parameters (kept conservative so walls remain)
wall            = 1.2;   // outer wall thickness
slot_open       = 2.2;   // opening at the surface for each T-slot
slot_depth      = 2.6;   // depth of slot from outer surface toward center
slot_inner_w    = 4.6;   // wider inner cavity width (T-slot undercut look)
center_hole_d   = 3.2;   // central bore diameter
eps             = 0.02;  // small overlap for robust boolean ops

module tslot_cut_x() {
    // Cuts a T-slot from +X face inward (along X), extruded along Z
    // Opening (narrow) near surface:
    translate([ profile_w/2 - slot_depth/2, 0, 0 ])
        cube([slot_depth + eps, slot_open, length + 2*eps], center=true);

    // Inner cavity (wider) slightly deeper:
    translate([ profile_w/2 - slot_depth + (slot_depth/2), 0, 0 ])
        cube([slot_depth + eps, slot_inner_w, length + 2*eps], center=true);
}

module tslot_cut_y() {
    // Cuts a T-slot from +Y face inward (along Y), extruded along Z
    translate([ 0, profile_h/2 - slot_depth/2, 0 ])
        cube([slot_open, slot_depth + eps, length + 2*eps], center=true);

    translate([ 0, profile_h/2 - slot_depth + (slot_depth/2), 0 ])
        cube([slot_inner_w, slot_depth + eps, length + 2*eps], center=true);
}

module extrusion_10x10(len=length) {
    // Ensure parameters don't destroy the profile
    assert(wall > 0);
    assert(slot_depth > 0 && slot_depth < profile_w/2);
    assert(slot_open > 0 && slot_open < profile_h - 2*wall);
    assert(slot_inner_w > slot_open && slot_inner_w < profile_h - 2*wall);

    color("Silver")
    difference() {
        // Outer body
        cube([profile_w, profile_h, len], center=true);

        // Central bore
        cylinder(h=len + 2*eps, d=center_hole_d, center=true);

        // Four T-slots (one per face), made by rotating the same cutters
        // +X face
        tslot_cut_x();
        // -X face
        rotate([0,0,180]) tslot_cut_x();

        // +Y face
        tslot_cut_y();
        // -Y face
        rotate([0,0,180]) tslot_cut_y();

        // Optional: keep a minimum wall at corners by trimming slot reach (implicit via slot_depth)
        // No extra arbitrary translations.
    }
}

extrusion_10x10(length);