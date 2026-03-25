module radial() {
    difference() {
        cylinder(h=0.5, r1=17.4, r2=11.4, $fn=64);
        translate([0, 0, -1])
            cylinder(h=2, r=9, $fn=64);
    }
}

radial();