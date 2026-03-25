module standoff_pillar() {
    difference() {
        cylinder(h=16.0, d=3.17, $fn=64);
        translate([0, 0, -1])
            cylinder(h=18.0, d=2.0, $fn=64);
    }
}

standoff_pillar();