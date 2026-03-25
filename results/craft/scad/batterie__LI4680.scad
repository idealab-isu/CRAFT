$fn = 128;

// Target overall size
height_mm   = 80.2;
diameter_mm = 46.2;

// Terminal details (kept within overall height)
positive_terminal_diameter_mm = 18.0;
positive_terminal_height_mm   = 2.0;

negative_terminal_diameter_mm = 20.0;
negative_terminal_height_mm   = 0.8;

overlap_mm = 0.6; // small overlap to guarantee one connected solid

module battery_cell() {
    r_body = diameter_mm/2;

    // Keep total height exactly height_mm by shortening the main body
    body_h = height_mm - positive_terminal_height_mm - negative_terminal_height_mm;

    union() {
        // Main cylindrical body centered at origin
        cylinder(h=body_h, r=r_body, center=true);

        // Positive terminal on top (connected with overlap)
        translate([0, 0, body_h/2 + positive_terminal_height_mm/2 - overlap_mm])
            cylinder(h=positive_terminal_height_mm, r=positive_terminal_diameter_mm/2, center=true);

        // Negative terminal on bottom (connected with overlap)
        translate([0, 0, -(body_h/2 + negative_terminal_height_mm/2 - overlap_mm)])
            cylinder(h=negative_terminal_height_mm, r=negative_terminal_diameter_mm/2, center=true);
    }
}

battery_cell();