$fn=96;

// Parameters
rod_d = 16.0;
height = 27.0;

// Typical SK16-style proportions (parametric, derived from rod size)
base_len = 42.0;
base_w   = 14.0;
base_th  = 6.0;

block_len = 42.0;
block_w   = 14.0;
block_h   = height;

rod_center_z = base_th + (block_h - base_th)/2; // keep bore centered in upper block region
rod_center_z = base_th + (block_h - base_th)/2;

bore_d = rod_d + 0.3;          // clearance
clamp_gap = 2.0;               // slit width
clamp_screw_d = 5.2;           // M5 clearance
clamp_screw_head_d = 9.5;      // socket head counterbore
clamp_screw_head_h = 5.0;

mount_hole_d = 5.2;            // M5 clearance
mount_counterbore_d = 9.5;
mount_counterbore_h = 4.0;

mount_hole_x = 16.0;           // spacing from center
mount_hole_y = 0.0;

edge_round_r = 1.0;

// Helpers
module rounded_block(size=[10,10,10], r=1.0){
    // Minkowski rounding (light)
    minkowski(){
        cube([size[0]-2*r, size[1]-2*r, size[2]-2*r], center=true);
        sphere(r=r);
    }
}

module bracket(){
    difference(){
        // Main body: base + upper block (same footprint)
        union(){
            // Base
            translate([0,0,base_th/2])
                rounded_block([base_len, base_w, base_th], r=edge_round_r);

            // Upper block
            translate([0,0,base_th + (block_h-base_th)/2])
                rounded_block([block_len, block_w, block_h-base_th], r=edge_round_r);
        }

        // Rod bore (along X)
        translate([0,0,rod_center_z])
            rotate([0,90,0])
                cylinder(d=bore_d, h=block_len+2, center=true);

        // Clamp slit (from top down to bore)
        translate([0,0,rod_center_z + bore_d/2])
            cube([block_len+2, clamp_gap, block_h], center=true);

        // Clamp screw (across Y, through block above bore)
        clamp_z = rod_center_z + bore_d*0.55;
        translate([0,0,clamp_z])
            rotate([90,0,0]){
                // Through hole
                cylinder(d=clamp_screw_d, h=block_w+2, center=true);
                // Counterbore on one side
                translate([0,0,(block_w/2 - clamp_screw_head_h/2)])
                    cylinder(d=clamp_screw_head_d, h=clamp_screw_head_h, center=true);
            }

        // Mounting holes (vertical) with counterbores from bottom
        for(x=[-mount_hole_x, mount_hole_x]){
            translate([x,mount_hole_y,0]){
                // Through
                cylinder(d=mount_hole_d, h=block_h+2, center=false);
                // Counterbore from bottom
                translate([0,0,0])
                    cylinder(d=mount_counterbore_d, h=mount_counterbore_h, center=false);
            }
        }
    }
}

bracket();