// Aluminium extrusion profile (simplified but verifiable)
// Exact overall size: 15mm x 15mm cross-section, 100mm length
// One connected solid (single difference() from one outer body)

$fn = 64;

// Parameters (fixed to requested dimensions)
cross_section_width_mm  = 15.0;
cross_section_height_mm = 15.0;
length_mm               = 100.0;

// Small overlap for robust boolean operations
overlap_mm = 0.2;

// Outer corner radius (kept modest)
outer_corner_radius_mm = 0.8;

// Internal features (kept similar to original intent)
center_bore_radius_mm = 2.5;

slot_opening_width_mm = 3.2;
slot_opening_depth_mm = 2.2;

slot_cavity_width_mm  = 6.2;
slot_cavity_depth_mm  = 4.2;

cornerHole = 1;
corner_hole_radius_mm = 1.6;
corner_hole_offset_from_corner_mm = 3.0;

// ---- Helpers ----
module rounded_square_2d(w, h, r) {
    r2 = min(r, min(w, h)/2);
    hull() {
        translate([ w/2 - r2,  h/2 - r2]) circle(r=r2);
        translate([-w/2 + r2,  h/2 - r2]) circle(r=r2);
        translate([-w/2 + r2, -h/2 + r2]) circle(r=r2);
        translate([ w/2 - r2, -h/2 + r2]) circle(r=r2);
    }
}

module outer_body() {
    // Extrude along Z to make a 100mm long profile
    linear_extrude(height=length_mm, center=true, convexity=10)
        rounded_square_2d(cross_section_width_mm, cross_section_height_mm, outer_corner_radius_mm);
}

module slot_cuts() {
    // Slots cut from each face, positioned by formulas from dimensions
    // X+ face
    translate([ cross_section_width_mm/2 - (slot_opening_depth_mm)/2, 0, 0])
        cube([slot_opening_depth_mm + 2*overlap_mm, slot_opening_width_mm, length_mm + 2*overlap_mm], center=true);
    translate([ cross_section_width_mm/2 - (slot_cavity_depth_mm)/2, 0, 0])
        cube([slot_cavity_depth_mm + 2*overlap_mm, slot_cavity_width_mm, length_mm + 2*overlap_mm], center=true);

    // X- face
    translate([-cross_section_width_mm/2 + (slot_opening_depth_mm)/2, 0, 0])
        cube([slot_opening_depth_mm + 2*overlap_mm, slot_opening_width_mm, length_mm + 2*overlap_mm], center=true);
    translate([-cross_section_width_mm/2 + (slot_cavity_depth_mm)/2, 0, 0])
        cube([slot_cavity_depth_mm + 2*overlap_mm, slot_cavity_width_mm, length_mm + 2*overlap_mm], center=true);

    // Y+ face
    translate([0, cross_section_height_mm/2 - (slot_opening_depth_mm)/2, 0])
        cube([slot_opening_width_mm, slot_opening_depth_mm + 2*overlap_mm, length_mm + 2*overlap_mm], center=true);
    translate([0, cross_section_height_mm/2 - (slot_cavity_depth_mm)/2, 0])
        cube([slot_cavity_width_mm, slot_cavity_depth_mm + 2*overlap_mm, length_mm + 2*overlap_mm], center=true);

    // Y- face
    translate([0, -cross_section_height_mm/2 + (slot_opening_depth_mm)/2, 0])
        cube([slot_opening_width_mm, slot_opening_depth_mm + 2*overlap_mm, length_mm + 2*overlap_mm], center=true);
    translate([0, -cross_section_height_mm/2 + (slot_cavity_depth_mm)/2, 0])
        cube([slot_cavity_width_mm, slot_cavity_depth_mm + 2*overlap_mm, length_mm + 2*overlap_mm], center=true);
}

module corner_hole_cuts() {
    if (cornerHole) {
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([
                sx*(cross_section_width_mm/2  - corner_hole_offset_from_corner_mm),
                sy*(cross_section_height_mm/2 - corner_hole_offset_from_corner_mm),
                0
            ])
            cylinder(r=corner_hole_radius_mm, h=length_mm + 2*overlap_mm, center=true);
        }
    }
}

// ---- Main model ----
module extrusion() {
    color("Silver")
    difference() {
        outer_body();

        // Center bore
        cylinder(r=center_bore_radius_mm, h=length_mm + 2*overlap_mm, center=true);

        // T-slots
        slot_cuts();

        // Optional corner holes
        corner_hole_cuts();
    }
}

extrusion();