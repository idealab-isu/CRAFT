module chamfered_bar() {
    difference() {
        // Main bar with chamfered edges
        hull() {
            translate([-0.05, -0.2, -0.05])
                cube([0.1, 0.4, 0.1]);
            translate([-0.05, -0.2, 0.05])
                cube([0.1, 0.4, 0.1]);
        }
        
        // Recessed panel on broad faces
        translate([-0.045, -0.195, -0.045])
            cube([0.09, 0.39, 0.09]);
        
        // Concave curvature on top and bottom
        translate([-0.05, -0.2, -0.05])
            intersection() {
                cube([0.1, 0.4, 0.1]);
                translate([0, 0, 0.05])
                    scale([1, 1, 0.5])
                    cylinder(h=0.1, r=0.1, $fn=64);
            }
        translate([-0.05, -0.2, -0.05])
            intersection() {
                cube([0.1, 0.4, 0.1]);
                translate([0, 0, -0.05])
                    scale([1, 1, 0.5])
                    cylinder(h=0.1, r=0.1, $fn=64);
            }
    }
    
    // Central rib/step
    translate([-0.025, -0.2, -0.005])
        cube([0.05, 0.4, 0.01]);
}

chamfered_bar();