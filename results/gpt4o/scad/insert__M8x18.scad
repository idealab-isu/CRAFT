module threaded_heat_set_insert() {
    difference() {
        // Outer cylinder
        cylinder(h=16.0, d=18.0, $fn=64);
        
        // Inner threaded hole for 8.0mm screws
        translate([0, 0, -1])
            cylinder(h=18.0, d=8.0, $fn=64);
    }
}

threaded_heat_set_insert();