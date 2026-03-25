module prismatic_bar() {
    // Main body dimensions
    body_length = 100;
    body_width = 10;
    body_height = 10;
    
    // Tapered nose dimensions
    nose_length = 20;
    nose_width = 5;
    nose_height = 5;
    
    // Forked end dimensions
    fork_length = 10;
    fork_width = 10;
    fork_height = 10;
    slot_width = 4;
    slot_depth = 5;
    
    // Hole dimensions
    hole_diameter = 2;
    hole_spacing = 4;
    
    // Create the main body with a tapered nose
    difference() {
        union() {
            // Main body
            translate([0, 0, 0])
                cube([body_length, body_width, body_height]);
            
            // Tapered nose
            translate([body_length, (body_width - nose_width) / 2, (body_height - nose_height) / 2])
                scale([1, nose_width / body_width, nose_height / body_height])
                rotate([0, 90, 0])
                cylinder(h = nose_length, r1 = body_width / 2, r2 = 0, $fn = 64);
        }
        
        // Forked U-shaped slot
        translate([body_length - fork_length, (body_width - slot_width) / 2, (body_height - slot_depth) / 2])
            cube([fork_length, slot_width, slot_depth]);
    }
    
    // Add holes on the wider end
    for (i = [-1, 0, 1]) {
        translate([body_length - fork_length - 1, body_width / 2 + i * hole_spacing, body_height / 2])
            rotate([90, 0, 0])
            cylinder(h = body_width, d = hole_diameter, $fn = 64);
    }
}

prismatic_bar();