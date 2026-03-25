module shaft_support_bracket() {
    difference() {
        union() {
            // Base block
            translate([-15, -15, 0])
                cube([30, 30, 5]);
            
            // Vertical support
            translate([-5, -5, 5])
                cube([10, 10, 18]);
            
            // Horizontal support
            translate([-15, -5, 18])
                cube([30, 10, 5]);
            
            // Cylinder for rod
            translate([0, 0, 23])
                rotate([90, 0, 0])
                cylinder(h=10, d=12, $fn=64);
        }
        
        // Hole for rod
        translate([0, 0, 23])
            rotate([90, 0, 0])
            cylinder(h=10, d=12, $fn=64);
    }
}

shaft_support_bracket();