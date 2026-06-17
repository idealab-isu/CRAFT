// Battery cell (single connected solid)
// Target overall: 70.2mm tall, 32.4mm diameter

height_mm = 70.2; //[35.1:140.4:0.1]
diameter_mm = 32.4; //[16.2:64.8:0.1]

positive_terminal_diameter_mm = 10; //[5:20:0.1]
positive_terminal_height_mm   = 1.5; //[0.75:3:0.05]

negative_terminal_diameter_mm = 12; //[6:24:0.1]
negative_terminal_height_mm   = 0.2; //[0.1:0.4:0.01]

overlap_mm = 0.8; //[0.5:2:0.1]

$fn = 128;

module battery_cell() {
    body_r = diameter_mm/2;

    // Keep overall height exactly height_mm by making the main body shorter
    body_h = height_mm - positive_terminal_height_mm - negative_terminal_height_mm;

    union() {
        // Main body centered at origin
        cylinder(h=body_h, r=body_r, center=true);

        // Positive terminal: sits on top of body, overlaps slightly into it
        translate([0, 0, body_h/2 + positive_terminal_height_mm/2 - overlap_mm])
            cylinder(h=positive_terminal_height_mm,
                     r=positive_terminal_diameter_mm/2,
                     center=true, $fn=96);

        // Negative terminal: sits on bottom of body, overlaps slightly into it
        translate([0, 0, -(body_h/2 + negative_terminal_height_mm/2 - overlap_mm)])
            cylinder(h=negative_terminal_height_mm,
                     r=negative_terminal_diameter_mm/2,
                     center=true, $fn=96);
    }
}

battery_cell();