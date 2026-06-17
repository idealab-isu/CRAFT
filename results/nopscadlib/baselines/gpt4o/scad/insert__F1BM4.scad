module threaded_insert() {
    difference() {
        cylinder(h=6.3, d=8.2, $fn=64);
        translate([0, 0, -1])
            cylinder(h=8.3, d=4.0, $fn=64);
    }
}

threaded_insert();