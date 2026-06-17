$fn=96;

// Parameters
rod_d = 16.0;
height = 27.0;

// Typical SK16-style proportions (parametric, tuned for 16mm rod)
base_len = 42.0;
base_w   = 14.0;
base_th  = 6.0;

block_len = 42.0;
block_w   = 14.0;
block_h   = height;

rod_center_z = base_th + (block_h - base_th)/2; // centered in upper block region
rod_center_y = block_w/2;
rod_center_x = block_len/2;

clamp_slot_w = 2.2;     // slit width
clamp_slot_depth = block_w; // through width

// Mounting holes (M5 clearance)
mount_hole_d = 5.5;
mount_hole_x_offset = 10.0;
mount_hole_y = base_w/2;

// Clamp screw holes (M5 clearance) across the slit
clamp_hole_d = 5.5;
clamp_hole_z1 = rod_center_z + 7.0;
clamp_hole_z2 = rod_center_z - 7.0;
clamp_hole_x = rod_center_x + 12.0; // near slit side

module bracket() {
    difference() {
        // Main body
        union() {
            // Base
            translate([0, 0, 0])
                cube([base_len, base_w, base_th], center=false);

            // Upper block
            translate([0, 0, base_th])
                cube([block_len, block_w, block_h - base_th], center=false);
        }

        // Rod bore (through X)
        translate([rod_center_x, rod_center_y, rod_center_z])
            rotate([0,90,0])
                cylinder(d=rod_d, h=block_len + 2, center=true);

        // Clamp slit (from top down to bore)
        translate([block_len - 8.0, -1, rod_center_z])
            cube([clamp_slot_w, block_w + 2, block_h], center=true);

        // Mounting holes (through Z)
        for (x = [mount_hole_x_offset, base_len - mount_hole_x_offset]) {
            translate([x, mount_hole_y, -1])
                cylinder(d=mount_hole_d, h=base_th + 2, center=false);
        }

        // Clamp screw holes (through Y, crossing slit)
        for (z = [clamp_hole_z1, clamp_hole_z2]) {
            translate([clamp_hole_x, rod_center_y, z])
                rotate([90,0,0])
                    cylinder(d=clamp_hole_d, h=block_w + 2, center=true);
        }

        // Small relief at slit end to reduce stress (rounded pocket)
        translate([block_len - 8.0, rod_center_y, rod_center_z])
            rotate([0,90,0])
                cylinder(d=6.0, h=10.0, center=true);
    }
}

bracket();