module standoff_pillar() {
    difference() {
        cylinder(h = 20.0, d = 8.0, $fn = 64);
        translate([0, 0, -1])
            cylinder(h = 22.0, d = 4.0, $fn = 64);
    }
}

standoff_pillar();