module threaded_insert() {
    difference() {
        cylinder(h=3.6, d=4.0, $fn=64);
        translate([0, 0, -1]) {
            cylinder(h=5.6, d=2.0, $fn=64);
        }
    }
}

threaded_insert();