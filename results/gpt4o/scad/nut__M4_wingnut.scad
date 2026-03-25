module wing_nut() {
    difference() {
        // Main hexagonal body
        scale([1, 1, 0.375])
            rotate([0, 0, 30])
                cylinder(d=10, h=10, $fn=6);
        
        // Hole for the screw
        translate([0, 0, -5])
            cylinder(d=4, h=20, $fn=64);
        
        // Wings
        union() {
            translate([-5, 0, 0])
                rotate([0, 0, 90])
                    scale([1, 0.5, 1])
                        cylinder(d=10, h=3.75, $fn=64);
            translate([5, 0, 0])
                rotate([0, 0, 90])
                    scale([1, 0.5, 1])
                        cylinder(d=10, h=3.75, $fn=64);
        }
    }
}

wing_nut();