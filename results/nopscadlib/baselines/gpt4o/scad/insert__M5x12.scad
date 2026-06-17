module threaded_insert() {
    difference() {
        cylinder(h=10, d=12, $fn=64);
        translate([0, 0, -1])
            cylinder(h=12, d=5, $fn=64);
    }
}

threaded_insert();