$fn = 128;

// HT 75 pipe, length 1500 mm
// Assumptions (typical HT DN75): OD = 75 mm, wall thickness = 2.7 mm

od  = 75;
t   = 2.7;
len = 1500;

id = od - 2*t;

module ht_pipe(od, id, len) {
    eps = 0.2; // small overlap to avoid coplanar faces

    // Orient pipe along X so FRONT/BACK/LEFT/RIGHT orthographic views show the 1500 mm length
    rotate([0, 90, 0])
        difference() {
            cylinder(h = len, d = od, center = true);
            cylinder(h = len + 2*eps, d = id, center = true);
        }
}

ht_pipe(od, id, len);