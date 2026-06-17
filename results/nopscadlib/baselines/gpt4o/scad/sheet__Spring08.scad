module saw_blade() {
    difference() {
        // Main blade body
        translate([0, 0, -0.5])
        cube([100, 5, 1], center=true);
        
        // Teeth
        for (i = [-45:5:45]) {
            translate([i, 2.5, 0])
            rotate([0, 0, 45])
            cube([5, 2, 1], center=true);
        }
        
        // Hole for mounting
        translate([0, 0, -0.5])
        cylinder(h=2, r=2, $fn=64);
    }
}

saw_blade();