// Aluminium rectangular box section 20mm x 20mm x 2mm

outer_w = 20;
outer_h = 20;
t       = 2;
len     = 100;

centered = true;     // true = centered on Z, false = sits on Z=0
eps = 0.2;           // small extension to avoid coincident faces

inner_w = outer_w - 2*t;
inner_h = outer_h - 2*t;

module box_section_rect(ow, oh, wall, L, e=0.2, ctr=true) {
    iw = ow - 2*wall;
    ih = oh - 2*wall;

    // Guard against invalid dimensions
    assert(iw > 0 && ih > 0, "Wall thickness too large for given outer dimensions.");

    difference() {
        cube([ow, oh, L], center=ctr);
        // Inner void extended slightly beyond ends for a clean through-hole
        cube([iw, ih, L + 2*e], center=ctr);
    }
}

translate([0, 0, centered ? 0 : len/2])
    box_section_rect(outer_w, outer_h, t, len, eps, true);