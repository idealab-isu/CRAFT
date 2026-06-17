// Battery cell: 35.2mm tall, 16.4mm diameter (one connected solid)

height_mm   = 35.2;   // total height including terminals
diameter_mm = 16.4;

positive_terminal_diameter_mm = 5.5;
positive_terminal_height_mm   = 1.2;

negative_terminal_diameter_mm = 8.0;
negative_terminal_height_mm   = 0.2;

terminal_overlap_mm = 0.8;   // overlap into body to guarantee connectivity

$fn = 128;

module battery() {
    body_r = diameter_mm/2;

    // Clamp overlap so it never exceeds each terminal height
    pos_ov = min(terminal_overlap_mm, positive_terminal_height_mm);
    neg_ov = min(terminal_overlap_mm, negative_terminal_height_mm);

    // Body height chosen so overall height remains exactly height_mm
    // while still allowing overlap (overlap adds material but not overall height).
    body_h = height_mm - positive_terminal_height_mm - negative_terminal_height_mm + pos_ov + neg_ov;

    union() {
        // Main cylindrical body
        cylinder(h=body_h, r=body_r, center=true);

        // Positive terminal (top), connected with overlap into body
        translate([0, 0, body_h/2 + positive_terminal_height_mm/2 - pos_ov])
            cylinder(h=positive_terminal_height_mm,
                     r=positive_terminal_diameter_mm/2,
                     center=true);

        // Negative terminal (bottom), connected with overlap into body
        translate([0, 0, -body_h/2 - negative_terminal_height_mm/2 + neg_ov])
            cylinder(h=negative_terminal_height_mm,
                     r=negative_terminal_diameter_mm/2,
                     center=true);
    }
}

battery();