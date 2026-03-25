module brushless_dc_motor() {
    // Stator
    translate([0, 0, -9.5/2])
        cylinder(h=9.5, d=11.5, $fn=64);
    
    // Rotor
    translate([0, 0, -9.5/2])
        difference() {
            cylinder(h=9.5, d=11.5, $fn=64);
            translate([0, 0, -9.5/2])
                cylinder(h=9.5, d=9.5, $fn=64);
        }
}

brushless_dc_motor();