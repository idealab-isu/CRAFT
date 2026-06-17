$fn = 128;

// PTFE tubing (hollow cylinder) - units: mm
outer_d = 4.0;     // OD
inner_d = 2.0;     // ID
length  = 200.0;   // tube length

module ptfe_tube(od, id, h) {
    eps = 0.05; // small overlap to ensure robust boolean

    // Orient tube along X so it is clearly visible in front/back/left/right views
    rotate([0, 90, 0])
        difference() {
            cylinder(d = od, h = h, center = true);
            cylinder(d = id, h = h + 2*eps, center = true);
        }
}

ptfe_tube(outer_d, inner_d, length);