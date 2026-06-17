$fn = 96;

// Linear bearing block for 6.0mm shaft
// Overall block size: 30.0 x 25.0 x (set by block_h)
shaft_d = 6.0;

block_x = 30.0;
block_y = 25.0;
block_h = 16.0;

wall = 3.0;                 // minimum wall around bore
bore_clear = 0.35;          // clearance for shaft
bore_d = shaft_d + bore_clear;

corner_r = 2.5;

// Clamp slit + screw
slit_w = 1.2;
screw_d = 3.2;              // M3 clearance
nut_flat = 5.7;             // M3 hex nut across flats
nut_thk = 2.6;
nut_trap_depth = 3.2;

// Mounting holes (2x)
mount_d = 3.4;              // M3 clearance
mount_x_off = 10.0;         // from center along X
mount_y_off = 0.0;          // centered in Y

module rounded_block(x,y,z,r){
    // Rounded rectangle prism via hull of corner cylinders
    hull(){
        for (sx=[-1,1], sy=[-1,1]){
            translate([sx*(x/2 - r), sy*(y/2 - r), 0])
                cylinder(h=z, r=r);
        }
    }
}

module hex_prism(af, h){
    // Regular hex with across-flats = af
    // circumradius R = af / sqrt(3)
    R = af / sqrt(3);
    cylinder(h=h, r=R, $fn=6);
}

difference(){
    // Body
    rounded_block(block_x, block_y, block_h, corner_r);

    // Shaft bore (along X)
    translate([0,0,block_h/2])
        rotate([0,90,0])
            cylinder(h=block_x + 2, d=bore_d, center=true);

    // Clamp slit (from top down to bore)
    // Slit runs along X, centered in Y, starting at top surface
    translate([0,0,block_h - (block_h/2)])
        cube([block_x + 2, slit_w, block_h], center=true);

    // Clamp screw hole (along Y), placed above bore
    screw_z = block_h/2 + (bore_d/2 + wall*0.6);
    translate([0,0,screw_z])
        rotate([90,0,0])
            cylinder(h=block_y + 2, d=screw_d, center=true);

    // Nut trap on one side (negative Y side)
    translate([0, -(block_y/2 - nut_trap_depth/2), screw_z])
        rotate([90,0,0])
            hex_prism(nut_flat, nut_trap_depth + 0.2);

    // Mounting holes (through Z)
    for (sx=[-1,1]){
        translate([sx*mount_x_off, mount_y_off, 0])
            cylinder(h=block_h + 2, d=mount_d, center=false);
    }

    // Light chamfer-ish relief on bottom edges (simple)
    // (Optional) remove small wedges at bottom corners
    cham = 1.0;
    for (sx=[-1,1], sy=[-1,1]){
        translate([sx*(block_x/2 - cham), sy*(block_y/2 - cham), -0.01])
            rotate([0,0,45])
                cube([cham*2, cham*2, block_h*0.35], center=false);
    }
}