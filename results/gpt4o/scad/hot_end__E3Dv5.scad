module hot_end() {
    union() {
        // Nozzle
        translate([0, 0, -10])
            cylinder(h=10, d1=3.7, d2=5, $fn=64);
        
        // Barrel
        translate([0, 0, 0])
            cylinder(h=50, d=3.7, $fn=64);
        
        // Heat sink
        translate([0, 0, 50])
            cylinder(h=10, d1=5, d2=10, $fn=64);
    }
}

module filament_path() {
    translate([0, 0, -10])
        cylinder(h=70, d=1.75, $fn=64);
}

difference() {
    hot_end();
    filament_path();
}

translate([0, 0, -35])
    hot_end();