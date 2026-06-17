$fn = 96;

// Linear bearing block for 8.0mm shaft
// Overall block size: 42.0mm x 36.0mm x 20.0mm (height chosen as a practical default)

shaft_d = 8.0;

block_x = 42.0;
block_y = 36.0;
block_z = 20.0;

wall = 4.0;                 // minimum wall around bore
bore_d = shaft_d + 0.4;     // clearance for shaft
bore_len = block_x + 2.0;   // through bore

// Clamp slit and screw
slit_w = 1.2;
screw_d = 4.2;              // M4 clearance
nut_flat = 7.2;             // M4 nut across flats
nut_thk = 3.4;

// Mounting holes (4x)
mount_d = 5.2;              // M5 clearance
mount_edge_x = 7.0;
mount_edge_y = 7.0;

// Fillet approximation via minkowski with small sphere
fillet_r = 1.2;

module rounded_block(x,y,z,r){
    minkowski(){
        cube([x-2*r, y-2*r, z-2*r], center=true);
        sphere(r=r);
    }
}

module hex_prism(af, h){
    // across flats = af
    r = af / (2*cos(30));
    cylinder(h=h, r=r, $fn=6, center=true);
}

difference(){
    // Body
    rounded_block(block_x, block_y, block_z, fillet_r);

    // Shaft bore along X
    rotate([0,90,0])
        cylinder(h=bore_len, d=bore_d, center=true);

    // Clamp slit from top down to bore
    translate([0,0, block_z/2])
        cube([block_x+2, slit_w, block_z], center=true);

    // Clamp screw across Y (through), located above bore
    clamp_z = 3.0; // distance above bore center
    translate([0,0, clamp_z])
        rotate([90,0,0])
            cylinder(h=block_y+2, d=screw_d, center=true);

    // Nut trap on one side (negative Y)
    translate([0, -block_y/2 + (nut_thk/2 + 1.0), clamp_z])
        rotate([90,0,0])
            hex_prism(nut_flat, nut_thk);

    // Mounting holes (4x) through Z
    for (sx = [-1,1], sy = [-1,1]){
        translate([sx*(block_x/2 - mount_edge_x), sy*(block_y/2 - mount_edge_y), 0])
            cylinder(h=block_z+2, d=mount_d, center=true);
    }

    // Light counterbore on top for mounting screws (optional shallow)
    cb_d = 9.5;
    cb_h = 2.5;
    for (sx = [-1,1], sy = [-1,1]){
        translate([sx*(block_x/2 - mount_edge_x), sy*(block_y/2 - mount_edge_y), block_z/2 - cb_h/2])
            cylinder(h=cb_h+0.2, d=cb_d, center=true);
    }
}