module link_plate() {
    difference() {
        // Main capsule shape
        union() {
            // Central rectangular part
            cube([29.2, 7.6, 2.5], center=true);
            // Rounded ends
            translate([-14.6, 0, 0])
                cylinder(h=2.5, r=3.8, $fn=64, center=true);
            translate([14.6, 0, 0])
                cylinder(h=2.5, r=3.8, $fn=64, center=true);
        }
        // Holes
        translate([-11.6, 0, 0])
            cylinder(h=3, r=1.5, $fn=64, center=true);
        translate([11.6, 0, 0])
            cylinder(h=3, r=1.5, $fn=64, center=true);
    }
}

link_plate();