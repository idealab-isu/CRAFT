$fn = 128;

// Parameters (mm)
overall_height_mm = 44.5;                 // total height
outer_diameter_mm = 10.5;                 // body diameter

positive_terminal_diameter_mm = 4.5;      // button diameter
positive_terminal_height_mm = 1.0;        // button height

negative_terminal_diameter_mm = 10.0;     // slight recess/plate diameter
negative_terminal_height_mm = 0.2;        // plate height

edge_chamfer_mm = 0.3;                    // end chamfer height
terminal_overlap_mm = 0.2;                // small overlap to guarantee connectivity

module battery() {
    r_body = outer_diameter_mm/2;
    r_pos  = positive_terminal_diameter_mm/2;
    r_neg  = negative_terminal_diameter_mm/2;

    // Ensure chamfers don't exceed available body length
    chamfer = min(edge_chamfer_mm, (overall_height_mm - positive_terminal_height_mm - negative_terminal_height_mm)/4);

    // Split total height into: bottom plate + main body + top button
    h_main = overall_height_mm - positive_terminal_height_mm - negative_terminal_height_mm;

    // Z references (centered model)
    z_bottom = -overall_height_mm/2;
    z_top    =  overall_height_mm/2;

    color("Silver")
    union() {
        // Main body with small end chamfers (connected solid)
        // Central straight section
        translate([0,0, z_bottom + negative_terminal_height_mm + chamfer + (h_main - 2*chamfer)/2])
            cylinder(h = max(0.01, h_main - 2*chamfer), r = r_body, center = true);

        // Bottom chamfer (taper to slightly smaller radius)
        translate([0,0, z_bottom + negative_terminal_height_mm + chamfer/2])
            cylinder(h = max(0.01, chamfer), r1 = max(0.01, r_body - chamfer), r2 = r_body, center = true);

        // Top chamfer (taper to slightly smaller radius)
        translate([0,0, z_top - positive_terminal_height_mm - chamfer/2])
            cylinder(h = max(0.01, chamfer), r1 = r_body, r2 = max(0.01, r_body - chamfer), center = true);

        // Negative terminal flat end-cap (slightly smaller than body, overlaps into body)
        translate([0,0, z_bottom + negative_terminal_height_mm/2 + terminal_overlap_mm/2])
            cylinder(h = negative_terminal_height_mm + terminal_overlap_mm, r = min(r_neg, r_body - 0.05), center = true);

        // Positive terminal button (overlaps into body)
        translate([0,0, z_top - positive_terminal_height_mm/2 - terminal_overlap_mm/2])
            cylinder(h = positive_terminal_height_mm + terminal_overlap_mm, r = r_pos, center = true);
    }
}

battery();