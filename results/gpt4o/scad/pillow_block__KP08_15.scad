module pillow_block_bearing() {
    // Base dimensions
    base_length = 55.0;
    base_width = 42.0;
    base_height = 5.0;
    
    // Bearing dimensions
    bearing_outer_diameter = 22.0;
    bearing_inner_diameter = 8.0;
    bearing_height = 12.0;
    
    // Hole dimensions
    hole_diameter = 5.0;
    hole_offset_x = 20.0;
    hole_offset_y = 15.0;
    
    // Create base
    difference() {
        translate([-base_length/2, -base_width/2, 0])
            cube([base_length, base_width, base_height]);
        
        // Create mounting holes
        translate([-hole_offset_x, -hole_offset_y, -1])
            cylinder(h=base_height + 2, d=hole_diameter, $fn=64);
        translate([hole_offset_x, -hole_offset_y, -1])
            cylinder(h=base_height + 2, d=hole_diameter, $fn=64);
        translate([-hole_offset_x, hole_offset_y, -1])
            cylinder(h=base_height + 2, d=hole_diameter, $fn=64);
        translate([hole_offset_x, hole_offset_y, -1])
            cylinder(h=base_height + 2, d=hole_diameter, $fn=64);
    }
    
    // Create bearing holder
    translate([0, 0, base_height])
        difference() {
            cylinder(h=bearing_height, d=bearing_outer_diameter, $fn=64);
            translate([0, 0, -1])
                cylinder(h=bearing_height + 2, d=bearing_inner_diameter, $fn=64);
        }
}

pillow_block_bearing();