// MGN12H carriage dimensions
carriage_length = 40;
carriage_width = 34;
carriage_height = 10;

// Mounting block dimensions
block_length = 50;
block_width = 40;
block_height = 15;

// M3 bolt hole dimensions
bolt_hole_diameter = 3.2;
bolt_hole_spacing_x = 20;
bolt_hole_spacing_y = 20;

// Create the mounting block
difference() {
    // Main block
    translate([-block_length/2, -block_width/2, 0])
        cube([block_length, block_width, block_height]);

    // Cut out space for the carriage
    translate([-carriage_length/2, -carriage_width/2, 0])
        cube([carriage_length, carriage_width, carriage_height]);

    // Bolt holes
    for (x = [-bolt_hole_spacing_x/2, bolt_hole_spacing_x/2])
        for (y = [-bolt_hole_spacing_y/2, bolt_hole_spacing_y/2])
            translate([x, y, -1])
                cylinder(h = block_height + 2, d = bolt_hole_diameter, $fn = 64);
}