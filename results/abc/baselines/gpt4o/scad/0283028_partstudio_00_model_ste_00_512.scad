module u_shaped_bracket() {
    difference() {
        // Main U-shaped bracket
        union() {
            // End blocks
            translate([-50, -10, -10])
                cube([20, 20, 20]);
            translate([30, -10, -10])
                cube([20, 20, 20]);
            // Connecting web
            translate([-30, -5, -5])
                cube([60, 10, 10]);
        }
        // Central cutout
        translate([-30, -5, -5])
            cube([60, 10, 10]);
    }
}

module countersunk_hole() {
    difference() {
        // Through hole
        translate([0, 0, -10])
            cylinder(h=20, r=2, $fn=64);
        // Countersink
        translate([0, 0, 0])
            cylinder(h=5, r1=4, r2=2, $fn=64);
    }
}

module bracket_with_holes() {
    u_shaped_bracket();
    // Left block hole
    translate([-40, 5, 0])
        countersunk_hole();
    // Right block hole
    translate([40, 5, 0])
        countersunk_hole();
}

module chamfered_bracket() {
    // Apply chamfers/fillets
    offset(r=1) {
        offset(delta=-1) {
            bracket_with_holes();
        }
    }
}

chamfered_bracket();