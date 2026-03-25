// Aluminium rectangular hollow box section: 38.1mm x 25.4mm x 1.6mm wall

outer_width_mm     = 38.1;
outer_height_mm    = 25.4;
wall_thickness_mm  = 1.6;
length_mm          = 200;

eps_mm = 0.02;

module box_section_rect_tube(ow, oh, t, L, center=true) {
    iw = ow - 2*t;
    ih = oh - 2*t;

    assert(iw > 0 && ih > 0, "Wall thickness too large for given outer dimensions.");

    difference() {
        cube([ow, oh, L], center=center);
        // Inner void: slightly longer to guarantee clean subtraction through the ends
        cube([iw, ih, L + 2*eps_mm], center=center);
    }
}

box_section_rect_tube(outer_width_mm, outer_height_mm, wall_thickness_mm, length_mm, true);