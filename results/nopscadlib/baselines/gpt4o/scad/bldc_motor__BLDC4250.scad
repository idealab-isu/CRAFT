module brushless_dc_motor() {
    // Stator
    cylinder(d=42.5, h=48.0, $fn=64);
    
    // Rotor
    translate([0, 0, 5])
        cylinder(d=40, h=38, $fn=64);
    
    // Shaft
    translate([0, 0, -10])
        cylinder(d=5, h=58, $fn=64);
}

brushless_dc_motor();