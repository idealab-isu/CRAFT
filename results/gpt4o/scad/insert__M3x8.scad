module threaded_heat_set_insert() {
    difference() {
        cylinder(d=8.0, h=6.0, $fn=64);
        translate([0, 0, -1]) {
            cylinder(d=3.0, h=8.0, $fn=64);
        }
    }
}

threaded_heat_set_insert();