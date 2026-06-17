module t_slot_nut() {
    difference() {
        // Main body of the T-slot nut
        cube([6.0, 6.0, 3.25], center = true);
        
        // Hole for the screw
        translate([0, 0, -3.25])
            cylinder(h = 6.5, d = 4.0, $fn = 64);
    }
}

t_slot_nut();