$fn = 128;

// PTFE tubing (hollow cylinder)
tube_length    = 120;  // mm
outer_diameter = 4;    // mm
inner_diameter = 2;    // mm

module ptfe_tube(L, OD, ID) {
    eps = 0.2; // small overlap to ensure clean boolean

    // Lay tube along X so front/back/left/right orthographic views show length
    rotate([0, 90, 0])
        difference() {
            cylinder(h = L, d = OD, center = true);
            cylinder(h = L + eps, d = ID, center = true);
        }
}

ptfe_tube(tube_length, outer_diameter, inner_diameter);