module t_slot_nut() {
    difference() {
        // Main body of the T-slot nut
        cube([6, 6, 2.75], center = true);
        
        // Hole for the screw
        translate([0, 0, -1.375])
            cylinder(h = 4, r = 1.5, $fn = 64);
    }
}

t_slot_nut();