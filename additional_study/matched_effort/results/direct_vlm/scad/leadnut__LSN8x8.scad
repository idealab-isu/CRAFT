$fn = 96;

// Overall block size (must match request)
block_x = 8.0;
block_y = 12.75;
block_z = 19.0;

// Feature parameters (typical small leadscrew nut housing)
bore_d      = 4.2;   // through-hole for leadscrew (along Z)
nut_flat    = 7.0;   // hex pocket across flats
nut_depth   = 6.0;   // depth of hex pocket from top face
mount_d     = 2.2;   // mounting through-holes (along Y)
mount_edge  = 2.0;   // distance from side faces to hole centers
mount_z_off = 4.0;   // distance from top/bottom faces to hole centers

eps = 0.02;

module hex_prism(af, h) {
    // Regular hex with across-flats = af
    r = af / sqrt(3); // circumradius
    cylinder(h=h, r=r, $fn=6, center=false);
}

difference() {
    // Main body: rectangular leadscrew nut housing block
    cube([block_x, block_y, block_z], center=false);

    // Leadscrew through-bore (along Z, centered in X/Y)
    translate([block_x/2, block_y/2, -eps])
        cylinder(h=block_z + 2*eps, d=bore_d, center=false);

    // Hex nut pocket from top face (coaxial with bore)
    translate([block_x/2, block_y/2, block_z - nut_depth])
        hex_prism(nut_flat, nut_depth + eps);

    // Two mounting through-holes (along Y), symmetric in X and Z
    // (2 holes total: left/right in X, centered in Z)
    for (sx = [-1, 1]) {
        translate([
            block_x/2 + sx*(block_x/2 - mount_edge),
            -eps,
            block_z/2
        ])
            rotate([90, 0, 0])
                cylinder(h=block_y + 2*eps, d=mount_d, center=false);
    }
}