module t_slot_nut() {
    difference() {
        // Main body of the nut
        cube([6.0, 6.0, 3.7], center = true);
        
        // Hole for the screw
        translate([0, 0, -3.7/2])
            cylinder(h = 3.7, r = 2.5, $fn = 64);
    }
}

t_slot_nut();