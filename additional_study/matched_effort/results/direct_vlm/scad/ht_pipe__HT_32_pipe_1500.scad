$fn = 128;

// HT 32 pipe (approx.): OD 32 mm, wall 1.8 mm, length 1500 mm
od = 32;
wall = 1.8;
id = od - 2*wall;
len = 1500;

module ht_pipe(od, id, len) {
    eps = 0.2; // small overlap to ensure clean boolean

    // Orient the pipe along X so front/back/left/right orthographic views show the 1500 mm length clearly
    rotate([0, 90, 0])
        difference() {
            cylinder(h=len, d=od, center=true);
            cylinder(h=len + 2*eps, d=id, center=true);
        }
}

ht_pipe(od, id, len);