module t_slot_nut() {
    difference() {
        // Main body of the T-slot nut
        cube([8, 8, 6.6], center=true);
        
        // Hole for the screw
        translate([0, 0, -3.3])
            cylinder(h=10, d=6, $fn=64);
    }
}

t_slot_nut();