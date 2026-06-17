module d_connector() {
    difference() {
        union() {
            // Main body
            translate([-30, -10, 0])
            cube([60, 20, 5]);

            // Rounded edges
            translate([-30, -10, 0])
            cylinder(h=5, r=10, $fn=64);
            translate([30, -10, 0])
            cylinder(h=5, r=10, $fn=64);
            translate([-30, 10, 0])
            cylinder(h=5, r=10, $fn=64);
            translate([30, 10, 0])
            cylinder(h=5, r=10, $fn=64);
        }
        
        // Cut out the inner part to form the D shape
        translate([-30, -10, -1])
        cube([60, 20, 6]);

        translate([-30, -10, 0])
        cylinder(h=6, r=8, $fn=64);
        translate([30, -10, 0])
        cylinder(h=6, r=8, $fn=64);
        translate([-30, 10, 0])
        cylinder(h=6, r=8, $fn=64);
        translate([30, 10, 0])
        cylinder(h=6, r=8, $fn=64);
    }
}

d_connector();