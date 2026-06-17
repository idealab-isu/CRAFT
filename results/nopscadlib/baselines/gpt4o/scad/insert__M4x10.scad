module threaded_heat_set_insert() {
    difference() {
        // Outer cylinder
        cylinder(h=8.0, d=10.0, $fn=64);
        
        // Inner thread space for 4.0mm screws
        translate([0, 0, -1]) {
            cylinder(h=10.0, d=4.0, $fn=64);
        }
    }
}

threaded_heat_set_insert();