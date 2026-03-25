module threaded_insert() {
    difference() {
        cylinder(h=4.6, d=3.0, $fn=64);
        translate([0, 0, -1])
            cylinder(h=6.6, d=2.0, $fn=64);
    }
}

threaded_insert();