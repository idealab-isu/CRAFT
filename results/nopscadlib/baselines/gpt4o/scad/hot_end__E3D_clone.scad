module hot_end() {
    union() {
        // Nozzle
        translate([0, 0, -6])
            cylinder(h=6, d1=6.8, d2=4, $fn=64);
        
        // Barrel
        translate([0, 0, 0])
            cylinder(h=60, d=6.8, $fn=64);
        
        // Filament path
        translate([0, 0, -6])
            cylinder(h=66, d=1.75, $fn=64);
    }
}

hot_end();