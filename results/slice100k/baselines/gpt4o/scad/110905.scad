module paddle() {
    // Main body dimensions
    body_length = 35.0;
    body_width = 10.0;
    body_height = 26.0;
    
    // Peg dimensions
    peg_length = 8.5;
    peg_diameter = 10.0;
    shoulder_height = 5.0;
    
    // Create the main body
    translate([-body_width/2, -body_length/2, -body_height/2])
        cube([body_width, body_length, body_height]);
    
    // Create the peg with a shoulder
    translate([-peg_diameter/2, body_length/2 - shoulder_height, -peg_diameter/2])
        union() {
            // Peg cylinder
            cylinder(h = peg_length, d = peg_diameter, $fn = 64);
            // Shoulder
            translate([0, 0, -shoulder_height])
                cylinder(h = shoulder_height, d = peg_diameter, $fn = 64);
        }
}

paddle();