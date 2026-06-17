// 15x15 aluminium extrusion profile, 100mm long (single connected solid)

$fn = 64;

// Parameters (mm)
cross_section_width_mm  = 15.0;
cross_section_height_mm = 15.0;
length_mm               = 100.0;

// Feature sizes (mm) - tuned for a small 15-series style profile
overlap_mm              = 0.2;   // small overlap for robust boolean ops
slot_opening_width_mm   = 3.2;   // mouth opening at the outer face
slot_inner_width_mm     = 6.2;   // wider cavity behind the mouth
slot_depth_mm           = 4.2;   // total depth from outer face to cavity end
slot_neck_depth_mm      = 1.6;   // depth of the narrow mouth section
center_bore_diameter_mm = 5.0;   // through bore
corner_relief_diameter_mm = 2.5; // small corner relief holes
corner_relief_offset_mm   = 3.2; // from outer corner along each axis

// Safety clamps to avoid invalid geometry
slot_neck_depth = min(slot_neck_depth_mm, slot_depth_mm - 0.1);
slot_depth      = min(slot_depth_mm, min(cross_section_width_mm, cross_section_height_mm)/2 - 0.5);
slot_open_w     = min(slot_opening_width_mm, min(cross_section_width_mm, cross_section_height_mm) - 2.0);
slot_inner_w    = min(slot_inner_width_mm,   min(cross_section_width_mm, cross_section_height_mm) - 1.0);

module tslot_cut_x(sign=1, h=10) {
    // Cuts a T-slot from the +X or -X face inward
    // sign = +1 for +X face, -1 for -X face
    union() {
        // Narrow mouth (neck) - reaches the outer face
        translate([sign*(cross_section_width_mm/2 - slot_neck_depth/2), 0, 0])
            cube([slot_neck_depth + 2*overlap_mm, slot_open_w, h], center=true);

        // Wider cavity behind the mouth
        translate([sign*(cross_section_width_mm/2 - slot_neck_depth - (slot_depth - slot_neck_depth)/2), 0, 0])
            cube([ (slot_depth - slot_neck_depth) + 2*overlap_mm, slot_inner_w, h], center=true);
    }
}

module tslot_cut_y(sign=1, h=10) {
    // Cuts a T-slot from the +Y or -Y face inward
    union() {
        translate([0, sign*(cross_section_height_mm/2 - slot_neck_depth/2), 0])
            cube([slot_open_w, slot_neck_depth + 2*overlap_mm, h], center=true);

        translate([0, sign*(cross_section_height_mm/2 - slot_neck_depth - (slot_depth - slot_neck_depth)/2), 0])
            cube([slot_inner_w, (slot_depth - slot_neck_depth) + 2*overlap_mm, h], center=true);
    }
}

module extrusion_15x15(len=100) {
    color("Silver")
    difference() {
        // Main body
        cube([cross_section_width_mm, cross_section_height_mm, len], center=true);

        // Center bore (through)
        cylinder(d=center_bore_diameter_mm, h=len + 2*overlap_mm, center=true);

        // Four T-slots (through along length)
        union() {
            tslot_cut_x(+1, len + 2*overlap_mm);
            tslot_cut_x(-1, len + 2*overlap_mm);
            tslot_cut_y(+1, len + 2*overlap_mm);
            tslot_cut_y(-1, len + 2*overlap_mm);
        }

        // Corner relief holes (through)
        if (corner_relief_diameter_mm > 0) {
            for (sx = [-1, 1], sy = [-1, 1]) {
                translate([
                    sx*(cross_section_width_mm/2  - corner_relief_offset_mm),
                    sy*(cross_section_height_mm/2 - corner_relief_offset_mm),
                    0
                ])
                cylinder(d=corner_relief_diameter_mm, h=len + 2*overlap_mm, center=true);
            }
        }
    }
}

// Single connected solid only
extrusion_15x15(length_mm);