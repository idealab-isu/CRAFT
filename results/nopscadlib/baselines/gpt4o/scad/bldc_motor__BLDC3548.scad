module brushless_dc_motor() {
    // Stator
    module stator() {
        cylinder(d=35.0, h=45.0, $fn=64);
    }
    
    // Rotor
    module rotor() {
        difference() {
            cylinder(d=33.0, h=45.0, $fn=64);
            translate([0, 0, -1])
                cylinder(d=20.0, h=47.0, $fn=64);
        }
    }
    
    // Shaft
    module shaft() {
        translate([0, 0, -10])
            cylinder(d=5.0, h=55.0, $fn=64);
    }
    
    // Assemble motor
    union() {
        stator();
        rotor();
        shaft();
    }
}

translate([0, 0, -22.5])
    brushless_dc_motor();