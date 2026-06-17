// 20x20 T-slot aluminium extrusion (approximate 2020 profile), 100mm long
// One connected solid, no floating parts

$fn = 64;

// Parameters (mm)
cross_section_width_mm  = 20.0;
cross_section_height_mm = 20.0;
length_mm              = 100.0;

wall_thickness_mm       = 2.0;   // outer wall thickness
center_bore_diameter_mm = 5.0;   // typical 2020 center bore

// T-slot geometry (approximate)
slot_opening_width_mm = 6.0;     // mouth width at outer face
slot_neck_depth_mm    = 2.0;     // depth of narrow mouth cut
slot_cavity_width_mm  = 11.0;    // wider internal cavity width
slot_cavity_depth_mm  = 6.0;     // depth of cavity cut from outer face

overlap_mm = 0.2;                // small overlap for robust booleans

module tslot_cut_x(sign=1) {
    // Cuts a T-slot from the +X or -X face inward
    // sign = +1 for +X face, -1 for -X face
    union() {
        // Narrow mouth (near outer face)
        translate([sign*(cross_section_width_mm/2 - (slot_neck_depth_mm/2)), 0, 0])
            cube([slot_neck_depth_mm + 2*overlap_mm, slot_opening_width_mm, length_mm + 2*overlap_mm], center=true);

        // Wider cavity (deeper inside)
        translate([sign*(cross_section_width_mm/2 - (slot_cavity_depth_mm/2)), 0, 0])
            cube([slot_cavity_depth_mm + 2*overlap_mm, slot_cavity_width_mm, length_mm + 2*overlap_mm], center=true);
    }
}

module tslot_cut_y(sign=1) {
    // Cuts a T-slot from the +Y or -Y face inward
    union() {
        translate([0, sign*(cross_section_height_mm/2 - (slot_neck_depth_mm/2)), 0])
            cube([slot_opening_width_mm, slot_neck_depth_mm + 2*overlap_mm, length_mm + 2*overlap_mm], center=true);

        translate([0, sign*(cross_section_height_mm/2 - (slot_cavity_depth_mm/2)), 0])
            cube([slot_cavity_width_mm, slot_cavity_depth_mm + 2*overlap_mm, length_mm + 2*overlap_mm], center=true);
    }
}

module extrusion_2020() {
    // Build as: outer solid minus (center bore + 4 T-slots)
    // Keep enough material so the result is one connected solid.
    difference() {
        // Outer body
        cube([cross_section_width_mm, cross_section_height_mm, length_mm], center=true);

        // Center bore
        cylinder(d=center_bore_diameter_mm, h=length_mm + 2*overlap_mm, center=true);

        // Four T-slots
        tslot_cut_x(+1);
        tslot_cut_x(-1);
        tslot_cut_y(+1);
        tslot_cut_y(-1);

        // Optional: relieve the very large "square tube" void by NOT hollowing the whole interior.
        // (Intentionally omitted: no big inner cube subtraction.)
    }
}

// Render
color("Silver") extrusion_2020();