module hot_end() {
    union() {
        // Nozzle
        translate([0, 0, -5])
            cylinder(h=10, d1=6, d2=3.7, $fn=64);
        
        // Barrel
        translate([0, 0, 5])
            cylinder(h=52, d=3.7, $fn=64);
        
        // Filament path
        translate([0, 0, -5])
            cylinder(h=62, d=1.75, $fn=64);
    }
}

hot_end();