// Aluminium rectangular box section: 20mm x 20mm x 2mm wall
// One connected hollow tube (open ends), constant section extrusion

outer_w = 20;
outer_h = 20;
wall_t  = 2;
length_L = 100;

eps = 0.05;

module box_section_tube(ow, oh, t, L) {
    iw = ow - 2*t;
    ih = oh - 2*t;

    assert(iw > 0 && ih > 0, "Wall thickness too large for given outer dimensions.");

    color("Silver")
    difference() {
        // Outer solid
        cube([ow, oh, L], center=true);

        // Inner void: slightly longer to guarantee a clean through-cut
        cube([iw, ih, L + 2*eps], center=true);
    }
}

box_section_tube(outer_w, outer_h, wall_t, length_L);