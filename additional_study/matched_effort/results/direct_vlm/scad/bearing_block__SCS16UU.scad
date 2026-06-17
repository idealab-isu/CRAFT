$fn = 128;

// Linear bearing block for 9.0mm shaft
shaft_d = 9.0;

// Overall block size (X x Y x Z)
block_x = 50.0;
block_y = 44.0;
block_z = 20.0;

corner_r = 4.0;

// Shaft bore (along X)
bore_clearance = 0.35;
bore_d = shaft_d + bore_clearance;

// Bearing seat (visual/functional feature around bore)
seat_clearance = 0.20;
seat_d = bore_d + 6.0;
seat_len = 28.0;

// Clamp slit (from top down to just above bore)
slit_w = 2.0;

// Mounting holes (4x)
mount_hole_d = 5.2;             // M5 clearance
mount_counterbore_d = 9.5;      // socket head counterbore
mount_counterbore_h = 4.0;

edge_margin_x = 8.0;
edge_margin_y = 8.0;

// Derived hole positions
hx = block_x/2 - edge_margin_x;
hy = block_y/2 - edge_margin_y;

// Bottom pocket
pocket_wall = 3.0;
pocket_depth = 6.0;
pocket_r = 2.0;

// Small overlap to avoid coplanar artifacts
eps = 0.2;

module rounded_block(x,y,z,r){
    // Rounded rectangle prism via hull of cylinders (Z from 0..z)
    hull(){
        for (sx = [-1,1], sy = [-1,1]){
            translate([sx*(x/2 - r), sy*(y/2 - r), 0])
                cylinder(h=z, r=r);
        }
    }
}

difference() {
    // BODY
    rounded_block(block_x, block_y, block_z, corner_r);

    // SHAFT BORE (through along X), centered in Y and Z
    // Use center=false cylinders and explicit placement so the cut is guaranteed to pass through the body.
    translate([-(block_x/2 + eps), 0, block_z/2])
        rotate([0, 90, 0])
            cylinder(h=block_x + 2*eps, d=bore_d, center=false);

    // BEARING SEAT / RELIEF (larger diameter, shorter length along X)
    translate([-(seat_len/2 + eps), 0, block_z/2])
        rotate([0, 90, 0])
            cylinder(h=seat_len + 2*eps, d=seat_d + seat_clearance, center=false);

    // CLAMP SLIT: from top down, STOP just above bore so the part remains ONE connected solid
    // Leave a small bridge thickness above the bore to keep connectivity.
    bridge_t = 1.2; // material left between slit bottom and bore top
    slit_depth = block_z/2 - (bore_d/2 + bridge_t);
    slit_depth = (slit_depth < 0) ? 0 : slit_depth;

    translate([0, 0, block_z - slit_depth/2 + eps])
        cube([block_x + 2*eps, slit_w, slit_depth + 2*eps], center=true);

    // MOUNTING HOLES + COUNTERBORES (from top)
    for (sx = [-1,1], sy = [-1,1]) {
        // Through hole
        translate([sx*hx, sy*hy, -eps])
            cylinder(h=block_z + 2*eps, d=mount_hole_d, center=false);

        // Counterbore from top face
        translate([sx*hx, sy*hy, block_z - mount_counterbore_h - eps])
            cylinder(h=mount_counterbore_h + 2*eps, d=mount_counterbore_d, center=false);
    }

    // BOTTOM LIGHTENING POCKET (leaves walls)
    translate([0, 0, -eps])
        linear_extrude(height=pocket_depth + 2*eps, center=false)
            offset(r=pocket_r)
                square([block_x - 2*pocket_wall, block_y - 2*pocket_wall], center=true);
}