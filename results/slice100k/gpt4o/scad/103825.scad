module u_shaped_bracket() {
    difference() {
        // Main U-shaped body
        union() {
            // Outer rounded back
            translate([0, 0, 39.5])
                rotate([90, 0, 0])
                cylinder(h=79, r=12.15, $fn=64);
            
            // Side walls
            translate([-11.05, -12.15, 0])
                cube([22.1, 24.3, 79]);
        }
        
        // Internal channel
        translate([-9.05, -10.15, 2])
            cube([18.1, 20.3, 75]);
        
        // Cylindrical through-holes
        translate([-11.05, 0, 65])
            rotate([90, 0, 0])
            cylinder(h=24.3, r=2, $fn=64);
        translate([11.05, 0, 65])
            rotate([90, 0, 0])
            cylinder(h=24.3, r=2, $fn=64);
    }
    
    // End tabs/lips
    translate([-11.05, -12.15, 0])
        cube([22.1, 2, 2]);
    translate([-11.05, 10.15, 0])
        cube([22.1, 2, 2]);
}

u_shaped_bracket();