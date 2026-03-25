module threaded_heat_set_insert() {
    difference() {
        // Outer cylinder
        cylinder(h=12.0, d=15.0, $fn=64);
        
        // Inner threaded hole for 6.0mm screws
        translate([0, 0, -1]) {
            cylinder(h=14.0, d=6.0, $fn=64);
        }
    }
}

threaded_heat_set_insert();