$fn = 96;

// Linear bearing block for 8.0mm shaft
// Overall block size: 40.0 x 35.0 x 20.0 (L x W x H)
// Shaft runs along the 40mm length (X axis)

shaft_d = 8.0;
block_L = 40.0;
block_W = 35.0;
block_H = 20.0;

clearance = 0.35;          // shaft clearance
bore_d = shaft_d + clearance;

wall_min = 4.0;            // minimum wall around bore
bore_z = block_H/2;        // center height

// Clamp slit and screw parameters
slit_w = 1.6;
screw_d = 4.2;             // M4 clearance
nut_flat = 7.2;            // M4 nut across flats
nut_thk = 3.4;
nut_trap_depth = 4.2;

// Mounting holes (to mount block to a plate)
mount_d = 5.2;             // M5 clearance
mount_x = 12.0;            // offset from ends
mount_y = 11.0;            // offset from sides

// Edge rounding
fillet_r = 2.0;

module rounded_block(L, W, H, r){
    // Minkowski with a sphere gives rounded edges/corners
    // Keep r modest to avoid excessive geometry
    minkowski(){
        cube([L-2*r, W-2*r, H-2*r], center=true);
        sphere(r=r);
    }
}

module nut_trap_hex(af, h){
    // Hex prism sized by across-flats (af)
    // Circumradius R = af / (2*cos(30))
    R = af / (2*cos(30));
    cylinder(h=h, r=R, $fn=6, center=true);
}

difference(){
    // Body
    translate([0,0,block_H/2])
        rounded_block(block_L, block_W, block_H, fillet_r);

    // Shaft bore along X
    translate([0,0,bore_z])
        rotate([0,90,0])
            cylinder(h=block_L+2, d=bore_d, center=true);

    // Clamp slit from top down to bore
    translate([0,0,block_H - (block_H/2)])
        translate([0,0,0])
            cube([block_L+2, slit_w, block_H+2], center=true);

    // Clamp screw through Y (crosswise), placed above bore
    screw_z = bore_z + (bore_d/2 + wall_min/2);
    translate([0,0,screw_z])
        rotate([90,0,0])
            cylinder(h=block_W+2, d=screw_d, center=true);

    // Nut trap on one side (negative Y side)
    translate([0, -(block_W/2 - nut_trap_depth/2), screw_z])
        rotate([90,0,0])
            nut_trap_hex(nut_flat, nut_thk);

    // Mounting holes (4x) through Z
    for (sx = [-1, 1])
    for (sy = [-1, 1]){
        translate([sx*(block_L/2 - mount_x), sy*(block_W/2 - mount_y), block_H/2])
            cylinder(h=block_H+2, d=mount_d, center=true);
    }
}