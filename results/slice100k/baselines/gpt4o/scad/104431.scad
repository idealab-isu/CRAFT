module chamfered_block() {
    difference() {
        // Main block with top and bottom taper
        hull() {
            translate([0, 0, -1]) scale([0.6, 0.6, 1]) cube([0.8, 0.8, 0.1], center=true);
            translate([0, 0, 1]) scale([0.6, 0.6, 1]) cube([0.8, 0.8, 0.1], center=true);
        }
        // Chamfered edges
        for (i = [0:3]) {
            rotate([0, 0, i * 90]) {
                translate([0.4, 0.4, 0]) {
                    rotate([45, 0, 0]) {
                        cube([0.2, 0.2, 2.4], center=true);
                    }
                }
            }
        }
    }
}

chamfered_block();