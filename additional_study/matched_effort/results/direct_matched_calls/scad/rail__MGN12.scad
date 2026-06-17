$fn = 64;

// Miniature linear guide rail
rail_w = 12.0;   // width (X)
rail_h = 8.0;    // height (Z)
rail_l = 100.0;  // length (Y)

module rail_body() {
    translate([-rail_w/2, 0, 0])
        cube([rail_w, rail_l, rail_h], center=false);
}

// Simple top chamfers to suggest a rail profile
module rail_profile() {
    chamfer = 1.0;
    difference() {
        rail_body();
        // top-left chamfer
        translate([-rail_w/2 - 0.01, -0.01, rail_h - chamfer])
            rotate([0, 45, 0])
                cube([chamfer*2, rail_l + 0.02, chamfer*2], center=false);
        // top-right chamfer
        translate([rail_w/2 - chamfer + 0.01, -0.01, rail_h - chamfer])
            rotate([0, -45, 0])
                cube([chamfer*2, rail_l + 0.02, chamfer*2], center=false);
    }
}

// Mounting holes along the centerline
module mounting_holes() {
    hole_d = 3.2;
    counterbore_d = 6.0;
    counterbore_depth = 2.0;

    // positions along length (Y)
    positions = [15, 35, 55, 75, 95];

    for (ypos = positions) {
        // through hole
        translate([0, ypos, -0.1])
            cylinder(d=hole_d, h=rail_h + 0.2);

        // counterbore from top
        translate([0, ypos, rail_h - counterbore_depth])
            cylinder(d=counterbore_d, h=counterbore_depth + 0.2);
    }
}

difference() {
    rail_profile();
    mounting_holes();
}