$fn = 96;

// Linear bearing block for 6.0mm shaft
// Block size: 34.0mm x 30.0mm (X x Y)
// Height chosen as a practical default for a small bearing block.

shaft_d = 6.0;
clearance = 0.25;          // shaft clearance
bore_d = shaft_d + clearance;

block_x = 34.0;
block_y = 30.0;
block_z = 16.0;

corner_r = 3.0;

// Clamp slit + screw
slit_w = 1.2;
slit_x = block_x/2 - 6.0;  // place slit near one side to create a clamp ear
screw_d = 3.2;             // M3 clearance
nut_flat = 5.7;            // M3 hex nut across flats
nut_th = 2.6;

mount_hole_d = 4.3;        // M4 clearance
mount_x_off = 11.0;
mount_y_off = 9.0;

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
    rounded_block(block_x, block_y, block_z, corner_r);

    // Shaft bore (along X)
    translate([0,0,block_z/2])
        rotate([0,90,0])
            cylinder(h=block_x+2, d=bore_d, center=true);

    // Clamp slit (cuts from top down to bore)
    translate([slit_x, 0, block_z/2])
        cube([slit_w, block_y+2, block_z+2], center=true);

    // Clamp screw hole (along Y), intersects slit region
    translate([slit_x, 0, block_z*0.70])
        rotate([90,0,0])
            cylinder(h=block_y+4, d=screw_d, center=true);

    // Nut trap on one side (negative Y)
    translate([slit_x, -block_y/2 + (nut_th/2 + 0.8), block_z*0.70])
        rotate([90,0,0])
            hex_prism(nut_flat, nut_th + 0.6);

    // Mounting holes (through Z), 4 holes
    for (sx=[-1,1], sy=[-1,1]){
        translate([sx*mount_x_off, sy*mount_y_off, 0])
            cylinder(h=block_z+2, d=mount_hole_d, center=false);
    }

    // Light chamfer-ish relief on bottom edges (simple)
    translate([0,0,-0.01])
        minkowski(){
            rounded_block(block_x-1.2, block_y-1.2, 0.6, max(0.1, corner_r-0.6));
            cylinder(h=0.01, r=0.6);
        }
}