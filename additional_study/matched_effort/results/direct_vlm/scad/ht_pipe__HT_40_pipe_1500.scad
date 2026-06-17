$fn = 128;

// HT 40 pipe (approx.): OD 40 mm, wall 1.8 mm, length 1500 mm
od = 40;
wall = 1.8;
len = 1500;

module ht_pipe(od, wall, len) {
    eps = 0.2; // overlap to avoid coplanar artifacts
    id = od - 2*wall;

    // Place pipe along X so front/back/left/right views show the full 1500 mm length
    rotate([0, 90, 0])
        difference() {
            cylinder(h=len, d=od, center=true);
            cylinder(h=len + 2*eps, d=id, center=true);
        }
}

ht_pipe(od, wall, len);