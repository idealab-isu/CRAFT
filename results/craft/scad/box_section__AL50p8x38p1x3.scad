// Aluminium rectangular box section: 50.8mm x 38.1mm x 3.0mm wall
// Single connected solid: hollow rectangular tube only (no extra features)

outer_width_mm     = 50.8;
outer_height_mm    = 38.1;
wall_thickness_mm  = 3.0;
length_mm          = 200;

eps_mm = 0.05; // small overlap to ensure robust boolean

module box_section_tube(ow, oh, t, L) {
    // Inner dimensions (must be positive)
    iw = ow - 2*t;
    ih = oh - 2*t;

    assert(iw > 0 && ih > 0, "Wall thickness too large for given outer dimensions.");

    // Use translate on inner cut so it is guaranteed to pass fully through the outer solid
    difference() {
        cube([ow, oh, L], center=true);
        translate([0, 0, 0])
            cube([iw, ih, L + 2*eps_mm], center=true);
    }
}

box_section_tube(outer_width_mm, outer_height_mm, wall_thickness_mm, length_mm);