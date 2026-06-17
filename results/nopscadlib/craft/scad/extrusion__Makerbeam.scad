// Aluminium extrusion profile: 10mm x 10mm cross section, 100mm long
// Single connected solid (one part). No floating helper geometry.

// Parameters
cross_section_width_mm  = 10.0;
cross_section_height_mm = 10.0;
length_mm               = 100.0;

wall_thickness_mm       = 1.2;
slot_width_mm           = 2.2;
slot_depth_mm           = 1.6;

center_hole_diameter_mm = 3.2;

corner_hole             = 1;
corner_hole_diameter_mm = 2.0;
corner_hole_inset_mm    = 2.5;

eps_mm                  = 0.05;

$fn = 96;

module extrusion_10x10_L100() {

    // Inner void dimensions (tube)
    inner_w = max(0.01, cross_section_width_mm  - 2*wall_thickness_mm);
    inner_h = max(0.01, cross_section_height_mm - 2*wall_thickness_mm);

    // Clamp slot sizes so they can't remove the whole body
    slot_w = min(slot_width_mm, min(cross_section_width_mm, cross_section_height_mm) - 2*wall_thickness_mm - 0.2);
    slot_d = min(slot_depth_mm, wall_thickness_mm - 0.2);

    // If wall is too thin for a slot, disable slots safely
    do_slots = (slot_w > 0.01) && (slot_d > 0.01);

    difference() {
        // Outer body: 10x10 cross-section, 100mm long along Z
        cube([cross_section_width_mm, cross_section_height_mm, length_mm], center=true);

        // Inner void: keep it slightly shorter than the outer to avoid coplanar artifacts
        cube([inner_w, inner_h, length_mm - 2*eps_mm], center=true);

        // T-slots: cut from each face inward, but never through the whole wall
        if (do_slots) {
            // +X face
            translate([cross_section_width_mm/2 - slot_d/2, 0, 0])
                cube([slot_d + 2*eps_mm, slot_w, length_mm + 2*eps_mm], center=true);

            // -X face
            translate([-cross_section_width_mm/2 + slot_d/2, 0, 0])
                cube([slot_d + 2*eps_mm, slot_w, length_mm + 2*eps_mm], center=true);

            // +Y face
            translate([0, cross_section_height_mm/2 - slot_d/2, 0])
                cube([slot_w, slot_d + 2*eps_mm, length_mm + 2*eps_mm], center=true);

            // -Y face
            translate([0, -cross_section_height_mm/2 + slot_d/2, 0])
                cube([slot_w, slot_d + 2*eps_mm, length_mm + 2*eps_mm], center=true);
        }

        // Center hole (through length)
        if (center_hole_diameter_mm > 0)
            cylinder(d=center_hole_diameter_mm, h=length_mm + 2*eps_mm, center=true);

        // Corner holes (through length)
        if (corner_hole && corner_hole_diameter_mm > 0) {
            inset_x = min(corner_hole_inset_mm, cross_section_width_mm/2 - wall_thickness_mm/2);
            inset_y = min(corner_hole_inset_mm, cross_section_height_mm/2 - wall_thickness_mm/2);

            for (sx = [-1, 1], sy = [-1, 1])
                translate([sx*(cross_section_width_mm/2 - inset_x),
                           sy*(cross_section_height_mm/2 - inset_y),
                           0])
                    cylinder(d=corner_hole_diameter_mm, h=length_mm + 2*eps_mm, center=true);
        }
    }
}

extrusion_10x10_L100();