module standoff_pillar() {
    difference() {
        cylinder(h = 13.0, d = 9.0, $fn = 64);
        translate([0, 0, -1])
            cylinder(h = 15.0, d = 3.0, $fn = 64);
    }
}

standoff_pillar();