// Battery cell: 80.2mm tall, 46.2mm diameter (one connected solid)

$fn = 128;

// Parameters
overall_height_mm = 80.2; //[40.1:160.4:0.1]
outer_diameter_mm = 46.2; //[23.1:92.4:0.1]

positive_terminal_diameter_mm = 18; //[9:36:0.1]
positive_terminal_height_mm   = 2;  //[1:4:0.1]

negative_terminal_diameter_mm = 12; //[6:24:0.1]
negative_terminal_height_mm   = 0.5;//[0.25:1:0.05]

terminal_overlap_mm = 1; //[0.5:2:0.1]

// Derived
body_height_mm   = overall_height_mm;
body_radius_mm   = outer_diameter_mm / 2;

// Battery - complete geometry (single connected solid)
module battery() {
    union() {
        // Main cylindrical body (not centered to avoid "blank" renders in some pipelines)
        cylinder(h=body_height_mm, r=body_radius_mm, center=false);

        // Positive terminal button (overlaps into body)
        translate([0, 0, body_height_mm - terminal_overlap_mm])
            cylinder(h=positive_terminal_height_mm, r=positive_terminal_diameter_mm/2, center=false, $fn=96);

        // Negative terminal contact (overlaps into body)
        translate([0, 0, -negative_terminal_height_mm + terminal_overlap_mm])
            cylinder(h=negative_terminal_height_mm, r=negative_terminal_diameter_mm/2, center=false, $fn=96);
    }
}

battery();