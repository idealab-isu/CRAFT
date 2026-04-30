$fn=64;

// MGN12H carriage mounting block (approximate)
// Units: mm

// ---- Parameters ----
block_len = 45;
block_wid = 30;
block_hgt = 12;

corner_r = 3;

m3_clear = 3.4;
m3_head_d = 6.2;     // socket cap head clearance
m3_head_h = 3.2;

carriage_hole_x = 20; // MGN12H hole spacing (approx)
carriage_hole_y = 15; // MGN12H hole spacing (approx)

edge_margin = 6;

// Optional side mounting holes (through width)
side_hole_d = 3.4;
side_hole_z = 6; // height from bottom
side_hole_x_offset = 12; // from center along length

// ---- Helpers ----
module rounded_block(l, w, h, r){
    // Rounded rectangle prism via hull of cylinders
    hull(){
        translate([ l/2 - r,  w/2 - r, 0]) cylinder(h=h, r=r);
        translate([-l/2 + r,  w/2 - r, 0]) cylinder(h=h, r=r);
        translate([ l/2 - r, -w/2 + r, 0]) cylinder(h=h, r=r);
        translate([-l/2 + r, -w/2 + r, 0]) cylinder(h=h, r=r);
    }
}

module m3_counterbore_through(h){
    // Through hole + counterbore from top
    union(){
        cylinder(h=h+0.2, d=m3_clear);
        translate([0,0,h - m3_head_h]) cylinder(h=m3_head_h+0.3, d=m3_head_d);
    }
}

module carriage_mount_holes(){
    for (sx = [-1, 1])
    for (sy = [-1, 1]){
        translate([sx*carriage_hole_x/2, sy*carriage_hole_y/2, 0])
            m3_counterbore_through(block_hgt);
    }
}

module side_mount_holes(){
    // Two holes through width, one near each end along length
    for (sx = [-1, 1]){
        translate([sx*side_hole_x_offset, 0, side_hole_z])
            rotate([90,0,0])
                cylinder(h=block_wid+0.6, d=side_hole_d, center=true);
    }
}

module lightening_pocket(){
    // Shallow pocket on underside to reduce weight
    pocket_len = block_len - 2*edge_margin;
    pocket_wid = block_wid - 2*edge_margin;
    pocket_hgt = 4;

    translate([0,0,0])
        translate([0,0,0])
            hull(){
                pr = 2.5;
                translate([ pocket_len/2 - pr,  pocket_wid/2 - pr, 0]) cylinder(h=pocket_hgt, r=pr);
                translate([-pocket_len/2 + pr,  pocket_wid/2 - pr, 0]) cylinder(h=pocket_hgt, r=pr);
                translate([ pocket_len/2 - pr, -pocket_wid/2 + pr, 0]) cylinder(h=pocket_hgt, r=pr);
                translate([-pocket_len/2 + pr, -pocket_wid/2 + pr, 0]) cylinder(h=pocket_hgt, r=pr);
            }
}

// ---- Model ----
difference(){
    // Main body centered at origin in X/Y, bottom at Z=0
    rounded_block(block_len, block_wid, block_hgt, corner_r);

    // Carriage mounting holes (top counterbore)
    carriage_mount_holes();

    // Side mounting holes
    side_mount_holes();

    // Underside pocket
    translate([0,0,0.6]) lightening_pocket();
}