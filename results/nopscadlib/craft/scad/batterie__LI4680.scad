// Battery cell: 80.2mm tall, 46.2mm diameter
$fn = 128;

// Parameters
body_height_mm = 80.2;
body_diameter_mm = 46.2;

positive_terminal_diameter_mm = 12;
positive_terminal_height_mm   = 2;

negative_terminal_diameter_mm = 18;
negative_terminal_height_mm   = 0.5;

terminal_overlap_mm = 0.8;   // ensures one connected solid

module battery() {
    body_r = body_diameter_mm/2;
    pos_r  = positive_terminal_diameter_mm/2;
    neg_r  = negative_terminal_diameter_mm/2;

    union() {
        // Main cylindrical body (base at z=0 for predictable placement)
        cylinder(h=body_height_mm, r=body_r, center=false);

        // Positive terminal button (top), overlaps into body
        translate([0, 0, body_height_mm - terminal_overlap_mm])
            cylinder(h=positive_terminal_height_mm, r=pos_r, center=false);

        // Negative terminal contact (bottom), overlaps into body
        translate([0, 0, -negative_terminal_height_mm + terminal_overlap_mm])
            cylinder(h=negative_terminal_height_mm, r=neg_r, center=false);
    }
}

battery();