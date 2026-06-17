// 15x15 aluminum extrusion profile, 100mm long (single connected solid)

profile_width_mm  = 15.0;
profile_height_mm = 15.0;
length_mm         = 100.0;

wall_thickness_mm       = 2.0;
slot_opening_mm         = 4.0;
slot_depth_mm           = 3.5;
slot_cavity_width_mm    = 7.0;
slot_cavity_depth_mm    = 5.0;
center_bore_diameter_mm = 5.0;

corner_relief_diameter_mm = 2.5;
corner_relief_offset_mm   = 3.0;

overlap_mm = 0.2;   // small overlap to avoid coincident faces
$fn = 64;

module extrusion_solid() {
    // Outer body
    difference() {
        cube([profile_width_mm, profile_height_mm, length_mm], center=true);

        // Center bore (through)
        cylinder(h=length_mm + 2*overlap_mm, r=center_bore_diameter_mm/2, center=true);

        // T-slot channels (4 sides), all positioned by formulas from dimensions
        union() {
            // X+ side
            translate([ profile_width_mm/2 - (slot_depth_mm + overlap_mm)/2, 0, 0])
                cube([slot_depth_mm + overlap_mm, slot_opening_mm, length_mm + 2*overlap_mm], center=true);
            translate([ profile_width_mm/2 - slot_depth_mm - (slot_cavity_depth_mm + overlap_mm)/2 + overlap_mm, 0, 0])
                cube([slot_cavity_depth_mm + overlap_mm, slot_cavity_width_mm, length_mm + 2*overlap_mm], center=true);

            // X- side
            translate([-profile_width_mm/2 + (slot_depth_mm + overlap_mm)/2, 0, 0])
                cube([slot_depth_mm + overlap_mm, slot_opening_mm, length_mm + 2*overlap_mm], center=true);
            translate([-profile_width_mm/2 + slot_depth_mm + (slot_cavity_depth_mm + overlap_mm)/2 - overlap_mm, 0, 0])
                cube([slot_cavity_depth_mm + overlap_mm, slot_cavity_width_mm, length_mm + 2*overlap_mm], center=true);

            // Y+ side
            translate([0,  profile_height_mm/2 - (slot_depth_mm + overlap_mm)/2, 0])
                cube([slot_opening_mm, slot_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
            translate([0,  profile_height_mm/2 - slot_depth_mm - (slot_cavity_depth_mm + overlap_mm)/2 + overlap_mm, 0])
                cube([slot_cavity_width_mm, slot_cavity_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);

            // Y- side
            translate([0, -profile_height_mm/2 + (slot_depth_mm + overlap_mm)/2, 0])
                cube([slot_opening_mm, slot_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
            translate([0, -profile_height_mm/2 + slot_depth_mm + (slot_cavity_depth_mm + overlap_mm)/2 - overlap_mm, 0])
                cube([slot_cavity_width_mm, slot_cavity_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
        }

        // Corner relief holes (through)
        union() {
            for (sx = [-1, 1], sy = [-1, 1])
                translate([sx*(profile_width_mm/2 - corner_relief_offset_mm),
                           sy*(profile_height_mm/2 - corner_relief_offset_mm), 0])
                    cylinder(h=length_mm + 2*overlap_mm, r=corner_relief_diameter_mm/2, center=true);
        }
    }
}

extrusion_solid();