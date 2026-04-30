$fn = 64;

module linear_shaft_bearing_block() {
    // Base flange
    base_flange();
    // Shaft bore
    translate([0, 0, 21])
        shaft_bore();
}

module base_flange() {
    difference() {
        // Base block
        cube([45, 28, 21], center = true);
        // Mounting holes
        translate([-11.5, -6.5, 0])
            mounting_hole();
        translate([11.5, -6.5, 0])
            mounting_hole();
        translate([-11.5, 6.5, 0])
            mounting_hole();
        translate([11.5, 6.5, 0])
            mounting_hole();
    }
}

module mounting_hole() {
    cylinder(h = 21, d = 4, center = true);
}

module shaft_bore() {
    translate([0, 0, 13])
        cylinder(h = 26, d = 8, center = true);
}

linear_shaft_bearing_block();