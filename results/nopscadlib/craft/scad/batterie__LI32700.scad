// Battery cell: 70.2mm tall, 32.4mm diameter
// One connected solid, no floating parts

height_mm   = 70.2;   //[35.1:140.4:0.1]
diameter_mm = 32.4;   //[16.2:64.8:0.1]

positive_terminal_diameter_mm = 10;   //[5:20:0.1]
positive_terminal_height_mm   = 1.5;  //[0.75:3:0.05]
negative_terminal_diameter_mm = 12;   //[6:24:0.1]
negative_terminal_height_mm   = 0.3;  //[0.15:0.6:0.01]

connect_overlap_mm = 0.8; //[0.5:2:0.1]
$fn = 128;

module battery_cell(h=height_mm, d=diameter_mm) {
    r = d/2;

    // Clamp overlap so it always creates a small intersection without inverting thin terminals
    ov_pos = min(connect_overlap_mm, positive_terminal_height_mm * 0.49);
    ov_neg = min(connect_overlap_mm, negative_terminal_height_mm * 0.49);

    union() {
        // Main body (centered)
        cylinder(h=h, r=r, center=true);

        // Positive terminal (top) - connected via calculated placement + overlap
        translate([0, 0, h/2 + positive_terminal_height_mm/2 - ov_pos])
            cylinder(h=positive_terminal_height_mm, r=positive_terminal_diameter_mm/2, center=true);

        // Negative terminal (bottom) - connected via calculated placement + overlap
        translate([0, 0, -h/2 - negative_terminal_height_mm/2 + ov_neg])
            cylinder(h=negative_terminal_height_mm, r=negative_terminal_diameter_mm/2, center=true);
    }
}

battery_cell();