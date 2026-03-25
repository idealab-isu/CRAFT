module stepped_cylinder() {
    difference() {
        // Flange
        cylinder(h=2.0, d=8.6, $fn=64);
        // Boss
        translate([0, 0, 2.0])
            cylinder(h=4.2, d=4.0, $fn=64);
    }
}

stepped_cylinder();