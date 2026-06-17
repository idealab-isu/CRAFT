module threaded_insert() {
    difference() {
        // Outer cylinder
        cylinder(h=4.6, d=4.0, $fn=64);
        // Inner thread space for 2.5mm screw
        translate([0, 0, -1])
            cylinder(h=6.6, d=2.5, $fn=64);
    }
}

threaded_insert();