module threaded_heat_set_insert() {
    difference() {
        // Outer cylinder
        cylinder(h = 22.0, d = 30.0, $fn = 64);
        
        // Inner thread space
        translate([0, 0, -1])
        cylinder(h = 24.0, d = 12.0, $fn = 64);
    }
}

threaded_heat_set_insert();