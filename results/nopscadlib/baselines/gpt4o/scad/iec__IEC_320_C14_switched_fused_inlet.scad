module iec_power_inlet() {
    difference() {
        // Main body
        union() {
            // Main rectangular body
            translate([-20, -13.5, 0])
                cube([40, 27, 20]);
            
            // Fuse holder
            translate([-5, 13.5, 0])
                cube([10, 5, 15]);
            
            // Switch
            translate([-15, -13.5, 20])
                cube([30, 10, 5]);
        }
        
        // Cutout for the inlet
        translate([-10, -5, 0])
            cube([20, 10, 20]);
        
        // Cutout for the fuse
        translate([-4, 14, 0])
            cube([8, 3, 15]);
        
        // Cutout for the switch
        translate([-14, -12.5, 20])
            cube([28, 8, 5]);
    }
}

iec_power_inlet();