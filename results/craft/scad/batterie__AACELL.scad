// Battery cell: 50.5mm tall, 14.5mm diameter (one connected solid)

// Parameters
overall_height_mm = 50.5;                 //[25.25:101:0.1]
outer_diameter_mm = 14.5;                 //[7.25:29:0.1]

positive_terminal_height_mm = 1;          //[0.5:2:0.05]
positive_terminal_diameter_mm = 5;        //[2.5:10:0.1]

negative_terminal_height_mm = 0.2;        //[0.1:0.6:0.05]
negative_terminal_diameter_mm = 10;       //[5:20:0.1]

terminal_overlap_mm = 0.8;                //[0.5:2:0.1]

// Derived: ensure total height matches overall_height_mm exactly
body_height_mm = overall_height_mm - positive_terminal_height_mm - negative_terminal_height_mm;

// AACELL - complete geometry (single connected solid)
module AACELL() {
    union() {
        // Main cylindrical body (centered)
        color("Silver")
            cylinder(r=outer_diameter_mm/2, h=body_height_mm, center=true, $fn=96);

        // Positive terminal button (connected with overlap)
        color("Gold")
            translate([0, 0, body_height_mm/2 + positive_terminal_height_mm/2 - terminal_overlap_mm])
                cylinder(r=positive_terminal_diameter_mm/2, h=positive_terminal_height_mm, center=true, $fn=64);

        // Negative terminal contact (connected with overlap)
        color("Copper")
            translate([0, 0, -body_height_mm/2 - negative_terminal_height_mm/2 + terminal_overlap_mm])
                cylinder(r=negative_terminal_diameter_mm/2, h=negative_terminal_height_mm, center=true, $fn=64);
    }
}

// Assembly
AACELL();