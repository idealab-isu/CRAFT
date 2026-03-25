module chamfered_block() {
    difference() {
        // Main block with chamfered corners
        hull() {
            translate([-50, -25, -10]) cube([100, 50, 20]);
            translate([-45, -20, -10]) cube([90, 40, 20]);
        }
        
        // Octagonal bore
        translate([0, 0, -10]) rotate([90, 0, 0]) cylinder(h=20, r=5, $fn=8);
        
        // Long narrow recessed slot
        translate([-40, -1, 9]) cube([80, 2, 2]);
        
        // Four small square recesses
        translate([-45, -20, 9]) cube([5, 5, 2]);
        translate([40, -20, 9]) cube([5, 5, 2]);
        translate([-45, 15, 9]) cube([5, 5, 2]);
        translate([40, 15, 9]) cube([5, 5, 2]);
    }
}

chamfered_block();