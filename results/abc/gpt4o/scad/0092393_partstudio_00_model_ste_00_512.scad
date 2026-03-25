module octagonal_ring() {
    difference() {
        // Outer octagonal profile
        scale([50, 50, 1])
        rotate([0, 0, 22.5])
        cylinder(r=1, h=0.1, $fn=8);
        
        // Inner circular opening
        translate([0, 0, -0.05])
        cylinder(r=0.3, h=0.2, $fn=64);
        
        // Square through-holes
        for (i = [0:7]) {
            rotate([0, 0, i * 45])
            translate([0.4, 0, -0.05])
            cube([0.1, 0.1, 0.2], center=true);
        }
    }
}

module chamfered_ring() {
    union() {
        // Main ring
        octagonal_ring();
        
        // Chamfered edges
        for (i = [0:7]) {
            rotate([0, 0, i * 45])
            translate([0.45, 0, 0])
            rotate([0, 45, 0])
            cube([0.1, 0.1, 0.1], center=true);
        }
    }
}

chamfered_ring();