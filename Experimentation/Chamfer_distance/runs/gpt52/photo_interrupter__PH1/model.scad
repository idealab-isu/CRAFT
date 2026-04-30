$fn = 64;

module photo_interrupter() {
    // Dimensions (mm)
    base_x = 25.9;
    base_y = 6.4;
    base_z = 3.5;

    gap_x = 5.9;      // slot width along X
    gap_y = 8.6;      // slot depth along Y (extends past base)
    gap_z = 7.2;      // slot height above base

    arm_t = 1.6;      // thickness of each arm (along X)
    body_x = gap_x + 2*arm_t; // overall fork width along X

    // Mounting holes
    hole_d = 3.0;
    hole_x_offset = 8.0;      // from center along X
    hole_y = 0;

    // Fork position on base
    fork_center_x = 0;
    fork_back_y = base_y/2 - 1.0; // near back edge
    fork_base_z = base_z;

    difference() {
        union() {
            // Base
            translate([0,0,base_z/2])
                cube([base_x, base_y, base_z], center=true);

            // Fork body (two arms + bridge)
            translate([fork_center_x, fork_back_y - gap_y/2, fork_base_z])
            union() {
                // Left arm
                translate([-(gap_x/2 + arm_t/2), 0, gap_z/2])
                    cube([arm_t, gap_y, gap_z], center=true);

                // Right arm
                translate([(gap_x/2 + arm_t/2), 0, gap_z/2])
                    cube([arm_t, gap_y, gap_z], center=true);

                // Back bridge connecting arms
                bridge_y = 2.2;
                translate([0, (gap_y/2 - bridge_y/2), gap_z/2])
                    cube([body_x, bridge_y, gap_z], center=true);

                // Small post/hood at top (typical interrupter cap)
                cap_z = 1.6;
                translate([0, (gap_y/2 - bridge_y), gap_z - cap_z/2])
                    cube([body_x, bridge_y*0.9, cap_z], center=true);
            }
        }

        // Slot cutout (optical gap)
        translate([fork_center_x, fork_back_y - gap_y/2, fork_base_z])
            translate([0,0,gap_z/2])
                cube([gap_x, gap_y, gap_z+0.2], center=true);

        // Mounting holes through base
        for (sx = [-1, 1]) {
            translate([sx*hole_x_offset, hole_y, 0])
                cylinder(d=hole_d, h=base_z+0.6, center=true);
        }
    }
}

photo_interrupter();