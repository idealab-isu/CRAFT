module rod_end() {
    union() {
        // Main body
        translate([0, 0, 10])
        cylinder(h=20, r=5, $fn=64);
        
        // Head
        translate([0, 0, 30])
        difference() {
            sphere(r=10, $fn=64);
            translate([0, 0, 30])
            cylinder(h=20, r=5, $fn=64);
        }
        
        // Hole in the head
        translate([0, 0, 30])
        cylinder(h=20, r=3, $fn=64);
    }
}

rod_end();