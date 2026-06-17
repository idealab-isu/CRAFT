module threaded_insert() {
    difference() {
        cylinder(h=7.1, d=5.8, $fn=64);
        translate([0, 0, -1])
            cylinder(h=9.1, d=5.0, $fn=64);
    }
}

threaded_insert();