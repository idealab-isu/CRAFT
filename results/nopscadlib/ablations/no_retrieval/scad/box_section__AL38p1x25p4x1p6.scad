// Aluminium rectangular box section: 38.1mm x 25.4mm x 1.6mm

outer_W   = 38.1;   // mm
outer_H   = 25.4;   // mm
wall_t    = 1.6;    // mm
length_L  = 1000;   // mm

eps = 0.01;         // small overlap to ensure robust boolean

module rectangular_tube(W, H, t, L) {
    inner_W = W - 2*t;
    inner_H = H - 2*t;

    assert(inner_W > 0 && inner_H > 0, "wall_t too large for given outer dimensions.");

    difference() {
        // Outer solid (tube body)
        cube([W, H, L], center=true);

        // Inner void (slightly longer so it fully cuts through)
        cube([inner_W, inner_H, L + 2*eps], center=true);
    }
}

rectangular_tube(outer_W, outer_H, wall_t, length_L);