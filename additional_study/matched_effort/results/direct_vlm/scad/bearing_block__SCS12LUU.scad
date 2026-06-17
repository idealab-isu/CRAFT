$fn = 96;

// Long linear bearing block for 8.0mm shaft
// Overall block size: 42.0mm x 70.0mm (X x Y)
// Height chosen as a reasonable default for an 8mm shaft block.

block_x = 42.0;
block_y = 70.0;
block_z = 24.0;

shaft_d = 8.0;
shaft_clear = 0.35;          // clearance for shaft
shaft_hole_d = shaft_d + shaft_clear;

bore_d = 15.0;               // internal bearing/bushing pocket diameter (typical for 8mm linear bearing)
bore_clear = 0.25;
bore_hole_d = bore_d + bore_clear;

bore_depth = 18.0;           // depth from top
top_wall = 3.0;              // remaining wall above bore

// Clamp slit and screw
slit_w = 1.6;
clamp_screw_d = 4.2;         // M4 clearance
clamp_screw_head_d = 8.2;    // socket head cap clearance
clamp_screw_head_h = 4.2;

// Mounting holes (4x) from bottom
mount_d = 5.4;               // M5 clearance
mount_cbore_d = 9.8;         // counterbore for M5 socket head
mount_cbore_h = 5.0;
mount_edge_x = 8.0;
mount_edge_y = 10.0;

module bearing_block() {
    difference() {
        // Body with slight edge rounding via minkowski (kept small for renderability)
        minkowski() {
            cube([block_x-2, block_y-2, block_z-1], center=true);
            sphere(r=1.0);
        }

        // Shaft through-hole along Y
        rotate([90,0,0])
            cylinder(d=shaft_hole_d, h=block_y+2, center=true);

        // Bearing/bushing pocket from top (along Z)
        translate([0,0, (block_z/2) - (bore_depth/2) - top_wall])
            cylinder(d=bore_hole_d, h=bore_depth, center=true);

        // Clamp slit from top down to shaft hole (along Y direction, thin cut)
        translate([0,0, block_z/2 - (bore_depth/2)])
            cube([block_x+2, slit_w, bore_depth+top_wall+2], center=true);

        // Clamp screw across X (tightening the slit), placed near top
        translate([0, 0, block_z/2 - (top_wall + 6.0)])
            rotate([0,90,0]) {
                // through hole
                cylinder(d=clamp_screw_d, h=block_x+4, center=true);
                // head recess on +X side
                translate([ (block_x/2) - (clamp_screw_head_h/2) + 0.5, 0, 0])
                    cylinder(d=clamp_screw_head_d, h=clamp_screw_head_h+1, center=true);
                // nut/driver recess on -X side (simple counterbore)
                translate([-(block_x/2) + (clamp_screw_head_h/2) - 0.5, 0, 0])
                    cylinder(d=clamp_screw_head_d, h=clamp_screw_head_h+1, center=true);
            }

        // Mounting holes (4x) from bottom with counterbore
        for (sx = [-1, 1], sy = [-1, 1]) {
            x = sx * (block_x/2 - mount_edge_x);
            y = sy * (block_y/2 - mount_edge_y);

            // through hole
            translate([x, y, 0])
                cylinder(d=mount_d, h=block_z+4, center=true);

            // counterbore from bottom
            translate([x, y, -(block_z/2) + mount_cbore_h/2])
                cylinder(d=mount_cbore_d, h=mount_cbore_h+1, center=true);
        }
    }
}

bearing_block();