module t_slot_nut() {
    difference() {
        // Main body of the T-slot nut
        cube([6, 6, 3], center = true);
        
        // Hole for the screw
        translate([0, 0, -1.5])
            cylinder(h = 5, r = 1.5, $fn = 64);
    }
}

t_slot_nut();