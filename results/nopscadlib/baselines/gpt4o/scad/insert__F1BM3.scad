module threaded_heat_set_insert() {
    difference() {
        // Outer cylinder
        cylinder(d=5.8, h=4.6, $fn=64);
        
        // Inner thread space for 3.0mm screw
        translate([0, 0, -1]) // Extend slightly below for better fit
        cylinder(d=3.0, h=6.6, $fn=64);
    }
}

threaded_heat_set_insert();