$fn=128;

module radial(r=[10.8, 10.8, 5.3, 1]) {
    // Interpret as: [outer_radius, inner_radius, height, wall_thickness]
    outer_r = r[0];
    inner_r = r[1];
    h       = r[2];
    t       = r[3];

    // If inner_r is given as same as outer_r, treat it as a ring defined by thickness t
    effective_inner = (inner_r >= outer_r) ? max(0, outer_r - t) : inner_r;

    difference() {
        cylinder(h=h, r=outer_r);
        translate([0,0,-0.01]) cylinder(h=h+0.02, r=effective_inner);
    }
}

radial([10.8, 10.8, 5.3, 1]);