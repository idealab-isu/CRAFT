// Battery cell parameters (mm)
height_mm = 61.5;                     // total height including terminals
diameter_mm = 34.2;                   // main can diameter

positive_terminal_diameter_mm = 8;
positive_terminal_height_mm   = 1.5;

negative_terminal_diameter_mm = 10;
negative_terminal_height_mm   = 0.3;

connect_overlap_mm = 0.8;             // ensures one connected solid

$fn = 128;

module battery() {
    r_body = diameter_mm/2;

    // Split total height into body + terminals so overall height matches height_mm
    body_h = height_mm - positive_terminal_height_mm - negative_terminal_height_mm;

    // Z positions computed from dimensions (no arbitrary numbers)
    z_body = (positive_terminal_height_mm - negative_terminal_height_mm)/2;
    z_pos  = z_body + body_h/2 + positive_terminal_height_mm/2 - connect_overlap_mm;
    z_neg  = z_body - body_h/2 - negative_terminal_height_mm/2 + connect_overlap_mm;

    color("Silver")
    union() {
        // Main cylindrical can
        translate([0, 0, z_body])
            cylinder(h=body_h, r=r_body, center=true);

        // Positive terminal button (top)
        translate([0, 0, z_pos])
            cylinder(h=positive_terminal_height_mm,
                     r=positive_terminal_diameter_mm/2,
                     center=true);

        // Negative terminal contact (bottom)
        translate([0, 0, z_neg])
            cylinder(h=negative_terminal_height_mm,
                     r=negative_terminal_diameter_mm/2,
                     center=true);
    }
}

battery();