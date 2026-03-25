module brushless_motor() {
    // Stator
    translate([0, 0, -4])
    cylinder(d=9.0, h=8.0, $fn=64);
    
    // Rotor
    translate([0, 0, -4])
    difference() {
        cylinder(d=8.0, h=8.0, $fn=64);
        translate([0, 0, -4])
        cylinder(d=6.0, h=8.0, $fn=64);
    }
    
    // Shaft
    translate([0, 0, -8])
    cylinder(d=2.0, h=16.0, $fn=64);
}

brushless_motor();