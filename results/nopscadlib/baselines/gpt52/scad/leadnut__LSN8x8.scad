$fn=64;

block_x = 8.0;
block_y = 12.75;
block_z = 19.0;

module nut_housing_body(x, y, z) {
    translate([-x/2, -y/2, -z/2])
        cube([x, y, z], center=false);
}

module leadscrew_bore(d, z, clearance=0.2) {
    cylinder(d=d+clearance, h=z+0.4, center=true);
}

module mounting_holes(y, z, d=2.6, y_offset=4.0, z_offset=6.0) {
    for (sy = [-1, 1], sz = [-1, 1]) {
        translate([0, sy*y_offset, sz*z_offset])
            rotate([0, 90, 0])
                cylinder(d=d, h=block_x+0.6, center=true);
    }
}

difference() {
    nut_housing_body(block_x, block_y, block_z);
    leadscrew_bore(8.0, block_z, clearance=0.3);
    mounting_holes(block_y, block_z, d=2.6, y_offset=4.0, z_offset=6.0);
}