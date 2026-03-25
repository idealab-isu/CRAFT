module radial() {
    difference() {
        cylinder(h=1, r=10.8/2, $fn=64);
        translate([0, 0, -0.1])
            cylinder(h=1.2, r=5.3/2, $fn=64);
    }
}

radial();