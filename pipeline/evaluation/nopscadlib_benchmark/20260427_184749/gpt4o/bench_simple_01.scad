module bearing_608() {
    difference() {
        // Outer cylinder
        cylinder(d=22, h=7, $fn=64);
        // Inner bore
        translate([0, 0, -1])
            cylinder(d=8, h=9, $fn=64);
    }
}

bearing_608();