// Define a module for a single segment of the seven-segment display
module segment() {
    cube([1.2, 12.7, 1.2], center = true);
}

// Define a module for the seven-segment digit
module seven_segment_digit() {
    translate([0, 0, 0.6])
    union() {
        // Horizontal segments
        translate([0, 6.35, 0]) segment();
        translate([0, -6.35, 0]) segment();
        translate([0, 0, 0]) segment();
        
        // Vertical segments
        rotate([0, 0, 90]) {
            translate([-3.0, 3.175, 0]) segment();
            translate([3.0, 3.175, 0]) segment();
            translate([-3.0, -3.175, 0]) segment();
            translate([3.0, -3.175, 0]) segment();
        }
    }
}

// Define a module for the LED display body
module display_body() {
    cube([12.7, 19, 8.2], center = true);
}

// Define a module for the pin grid
module pin_grid() {
    for (x = [-2, 2])
    for (y = [-1, 0, 1])
    translate([x * 3, y * 3, -4.1])
    cylinder(h = 2, r = 0.6, $fn = 64);
}

// Combine all parts to form the LED display module
module led_display_module() {
    difference() {
        display_body();
        translate([0, 0, 4.1]) seven_segment_digit();
        pin_grid();
    }
}

// Render the LED display module
translate([0, 0, 0]) led_display_module();