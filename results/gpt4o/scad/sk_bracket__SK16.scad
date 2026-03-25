module shaft_support_bracket() {
    difference() {
        union() {
            // Base block
            translate([-20, -20, 0])
                cube([40, 40, 10]);
            
            // Vertical support
            translate([-10, -10, 10])
                cube([20, 20, 17]);
            
            // Cylinder for rod
            translate([0, 0, 27])
                cylinder(h=10, d=20, $fn=64);
        }
        
        // Hole for the rod
        translate([0, 0, 27])
            cylinder(h=20, d=16, $fn=64);
    }
}

shaft_support_bracket();