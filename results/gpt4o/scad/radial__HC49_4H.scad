module radial() {
    difference() {
        cylinder(h=3.5, r=10.5, $fn=64);
        translate([0, 0, -0.1])
            cylinder(h=3.7, r=3.7, $fn=64);
    }
}

radial();