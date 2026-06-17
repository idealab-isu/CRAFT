module brushless_dc_motor() {
    union() {
        // Stator
        translate([0, 0, -11.75/2])
            cylinder(d=14.0, h=11.75, $fn=64);
        
        // Rotor
        translate([0, 0, -11.75/2])
            cylinder(d=12.0, h=11.75, $fn=64);
        
        // Shaft
        translate([0, 0, -11.75/2])
            cylinder(d=3.0, h=20.0, $fn=64);
    }
}

brushless_dc_motor();