// Battery cell: 65.0mm tall, 18.3mm diameter (single connected solid)

// Parameters
height_mm = 65.0;                     //[32.5:130:0.1]
diameter_mm = 18.3;                   //[9.15:36.6:0.1]

positive_terminal_diameter_mm = 5.5;  //[2.75:11:0.1]
positive_terminal_height_mm   = 1.5;  //[0.75:3:0.1]

negative_terminal_diameter_mm = 10.0; //[5:20:0.1]
negative_terminal_height_mm   = 0.2;  //[0.1:0.6:0.05]

terminal_overlap_mm = 0.8;            //[0.2:2:0.1]

$fn = 96;

module battery() {
    body_r = diameter_mm/2;
    pos_r  = positive_terminal_diameter_mm/2;
    neg_r  = negative_terminal_diameter_mm/2;

    // Ensure overlap is valid so parts always intersect the body
    ov_pos = min(terminal_overlap_mm, positive_terminal_height_mm*0.9);
    ov_neg = min(terminal_overlap_mm, negative_terminal_height_mm*0.9);

    union() {
        // Main cylindrical body (centered)
        cylinder(h=height_mm, r=body_r, center=true);

        // Positive terminal (top), overlaps into body
        translate([0, 0, height_mm/2 + positive_terminal_height_mm/2 - ov_pos])
            cylinder(h=positive_terminal_height_mm, r=pos_r, center=true);

        // Negative terminal (bottom), overlaps into body
        translate([0, 0, -height_mm/2 - negative_terminal_height_mm/2 + ov_neg])
            cylinder(h=negative_terminal_height_mm, r=neg_r, center=true);
    }
}

battery();