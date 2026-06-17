module brushless_dc_motor() {
    // Stator
    difference() {
        cylinder(h = 27.0, d = 28.0, $fn = 64);
        cylinder(h = 27.0, d = 20.0, $fn = 64);
    }
    
    // Rotor
    translate([0, 0, -2.0])
    difference() {
        cylinder(h = 31.0, d = 26.0, $fn = 64);
        translate([0, 0, -1.0])
        cylinder(h = 33.0, d = 22.0, $fn = 64);
    }
    
    // Shaft
    translate([0, 0, -5.0])
    cylinder(h = 37.0, d = 5.0, $fn = 64);
}

brushless_dc_motor();