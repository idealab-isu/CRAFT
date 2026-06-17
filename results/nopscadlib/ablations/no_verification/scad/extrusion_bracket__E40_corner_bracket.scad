$fn = 64;

// Target overall size (bracket envelope)
leg_length_x_mm = 40;   // X leg length
leg_length_y_mm = 40;   // Y leg length
height_z_mm     = 35;   // Z height

// Bracket details
wall_thickness_mm   = 5;
hole_diameter_mm    = 5.5;
hole_edge_offset_mm = 10;
relief_clearance_mm = 0.6;   // small clearance for inner relief
overlap_mm          = 0.8;   // ensures boolean robustness

// ---- Helpers ----
module l_bracket_solid() {
    // L-shaped solid made from two connected legs
    union() {
        // X leg
        translate([leg_length_x_mm/2, wall_thickness_mm/2, height_z_mm/2])
            cube([leg_length_x_mm, wall_thickness_mm, height_z_mm], center=true);

        // Y leg
        translate([wall_thickness_mm/2, leg_length_y_mm/2, height_z_mm/2])
            cube([wall_thickness_mm, leg_length_y_mm, height_z_mm], center=true);

        // Corner fill to avoid any internal seam
        translate([wall_thickness_mm/2, wall_thickness_mm/2, height_z_mm/2])
            cube([wall_thickness_mm, wall_thickness_mm, height_z_mm], center=true);
    }
}

module inner_relief_cut() {
    // Remove material to create a typical inner-corner relief (keeps L profile)
    // Leaves wall_thickness on both legs.
    translate([wall_thickness_mm + (leg_length_x_mm - wall_thickness_mm)/2,
               wall_thickness_mm + (leg_length_y_mm - wall_thickness_mm)/2,
               height_z_mm/2])
        cube([leg_length_x_mm - wall_thickness_mm + relief_clearance_mm,
              leg_length_y_mm - wall_thickness_mm + relief_clearance_mm,
              height_z_mm + 2*overlap_mm], center=true);
}

module mounting_holes_cut() {
    // Two holes through X-leg (along Y), and two holes through Y-leg (along X)
    zc = height_z_mm - hole_edge_offset_mm;

    // Holes through X-leg (axis Y)
    for (xpos = [hole_edge_offset_mm, leg_length_x_mm - hole_edge_offset_mm]) {
        translate([xpos, wall_thickness_mm/2, zc])
            rotate([90, 0, 0])
                cylinder(d=hole_diameter_mm, h=wall_thickness_mm + 2*overlap_mm, center=true);
    }

    // Holes through Y-leg (axis X)
    for (ypos = [hole_edge_offset_mm, leg_length_y_mm - hole_edge_offset_mm]) {
        translate([wall_thickness_mm/2, ypos, zc])
            rotate([0, 90, 0])
                cylinder(d=hole_diameter_mm, h=wall_thickness_mm + 2*overlap_mm, center=true);
    }
}

// ---- Final model (ONE connected solid) ----
difference() {
    l_bracket_solid();
    inner_relief_cut();
    mounting_holes_cut();
}