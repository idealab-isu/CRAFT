module pillow_block_bearing() {
    base_length = 67.0;
    base_width = 53.0;
    base_height = 10.0;
    bearing_diameter = 30.0;
    bearing_height = 20.0;
    shaft_diameter = 10.0;
    hole_diameter = 5.0;
    hole_offset = 20.0;
    hole_spacing = 47.0;
    $fn = 64;

    // Base
    difference() {
        translate([-base_length/2, -base_width/2, 0])
            cube([base_length, base_width, base_height]);
        // Holes for mounting
        translate([-hole_spacing/2, -hole_offset, -1])
            cylinder(h = base_height + 2, d = hole_diameter);
        translate([hole_spacing/2, -hole_offset, -1])
            cylinder(h = base_height + 2, d = hole_diameter);
        translate([-hole_spacing/2, hole_offset, -1])
            cylinder(h = base_height + 2, d = hole_diameter);
        translate([hole_spacing/2, hole_offset, -1])
            cylinder(h = base_height + 2, d = hole_diameter);
    }

    // Bearing
    translate([0, 0, base_height])
        difference() {
            cylinder(h = bearing_height, d = bearing_diameter);
            translate([0, 0, -1])
                cylinder(h = bearing_height + 2, d = shaft_diameter);
        }
}

pillow_block_bearing();