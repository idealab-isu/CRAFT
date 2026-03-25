module hot_end() {
    difference() {
        union() {
            // Barrel
            translate([0, 0, -25.6])
                cylinder(h=51.2, d=4.75, $fn=64);
            // Nozzle
            translate([0, 0, -30.6])
                cylinder(h=5, d1=4.75, d2=2, $fn=64);
        }
        // Filament path
        translate([0, 0, -30.6])
            cylinder(h=56.2, d=1.75, $fn=64);
    }
}

hot_end();