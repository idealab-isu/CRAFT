// Battery cell: 50.0mm tall, 26.2mm diameter (one connected solid)

height_mm = 50.0; //[25.0:100.0:0.1]
diameter_mm = 26.2; //[13.1:52.4:0.1]

positive_terminal_diameter_mm = 10.0; //[5.0:20.0:0.1]
positive_terminal_height_mm = 1.5; //[0.75:3.0:0.1]

negative_terminal_diameter_mm = 12.0; //[6.0:24.0:0.1]
negative_terminal_height_mm = 0.5; //[0.25:1.0:0.05]

terminal_overlap_mm = 1.0; //[0.5:2.0:0.1]

$fn = 128;

module battery_cell() {
    r_body = diameter_mm/2;

    // Ensure a real overlap (prevents coincident faces) and never exceed terminal height
    eps = 0.05;
    overlap_pos = min(positive_terminal_height_mm - eps, terminal_overlap_mm);
    overlap_neg = min(negative_terminal_height_mm - eps, terminal_overlap_mm);

    union() {
        // Main body
        cylinder(r=r_body, h=height_mm, center=true);

        // Positive terminal (top), overlaps into body
        translate([0, 0, height_mm/2 + positive_terminal_height_mm/2 - overlap_pos])
            cylinder(r=positive_terminal_diameter_mm/2, h=positive_terminal_height_mm, center=true);

        // Negative terminal (bottom), overlaps into body
        translate([0, 0, -height_mm/2 - negative_terminal_height_mm/2 + overlap_neg])
            cylinder(r=negative_terminal_diameter_mm/2, h=negative_terminal_height_mm, center=true);
    }
}

battery_cell();