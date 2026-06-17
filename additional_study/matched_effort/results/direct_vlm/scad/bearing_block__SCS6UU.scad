$fn = 96;

// Linear bearing block for 6.0mm shaft
// Overall block size: 30.0mm x 25.0mm (X x Y)
shaft_d = 6.0;

block_x = 30.0;
block_y = 25.0;
block_z = 15.0;

corner_r = 2.0;

// Through bore for shaft (along X)
shaft_clear = 0.25;
bore_d = shaft_d + shaft_clear;

// Clamp slot (opens from top down to the bore)
slot_w = 1.6;

// Clamp screw (M3) across Y direction, two screws along X
screw_d = 3.2;      // clearance for M3
head_d  = 6.2;      // cap head clearance
head_h  = 3.2;

screw_x_offset = 8.0;          // from center along X
screw_z = block_z * 0.70;      // height of clamp screws from bottom

eps = 0.02;

module rounded_block(x,y,z,r){
    r2 = min(r, min(x,y)/2);
    translate([0,0,-z/2])
        linear_extrude(height=z)
            offset(r=r2)
                square([x-2*r2, y-2*r2], center=true);
}

difference() {
    // Body centered at origin
    rounded_block(block_x, block_y, block_z, corner_r);

    // 6mm shaft bore THROUGH the block along X (clear, verifiable)
    rotate([0,90,0])
        cylinder(d=bore_d, h=block_x + 2, center=true);

    // Clamp slot from top face down to just above the bore (keeps ONE connected solid)
    // Leave a web below the slot so the part remains connected.
    web = 0.8; // material left between slot bottom and bore top
    bore_r = bore_d/2;
    slot_bottom_z = bore_r + web;                 // measured from center (z=0)
    slot_h = block_z/2 - slot_bottom_z;           // from slot bottom to top face
    translate([0, 0, slot_bottom_z + slot_h/2])
        cube([block_x + 2, slot_w, slot_h + 2*eps], center=true);

    // Two clamp screws across Y (through holes) + counterbore on +Y side
    for (sx = [-screw_x_offset, screw_x_offset]) {
        // Through hole across Y
        translate([sx, 0, -block_z/2 + screw_z])
            rotate([90,0,0])
                cylinder(d=screw_d, h=block_y + 2, center=true);

        // Counterbore for head on +Y side (connected, formula-based placement)
        translate([sx, block_y/2 - head_h/2 + eps, -block_z/2 + screw_z])
            rotate([90,0,0])
                cylinder(d=head_d, h=head_h + 0.6, center=true);
    }

    // Bottom bevel (inset cut)
    bevel = 0.8;
    translate([0,0,-block_z/2 - eps])
        linear_extrude(height=bevel + 2*eps)
            offset(delta=-bevel)
                square([block_x, block_y], center=true);
}