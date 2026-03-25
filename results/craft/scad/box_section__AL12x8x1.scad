// Aluminium rectangular hollow box section: 12mm x 8mm x 1mm wall

outer_width_mm     = 12;   // X
outer_height_mm    = 8;    // Y
wall_thickness_mm  = 1;    // wall thickness
length_mm          = 100;  // Z (extrusion length)
eps_mm             = 0.02; // small overlap to avoid coplanar faces

module box_section_rect_tube(ow, oh, t, L, eps=0.02) {
    iw = ow - 2*t;
    ih = oh - 2*t;

    assert(iw > 0 && ih > 0, "Wall thickness too large for given outer dimensions.");

    // Outer solid minus inner void (void is longer and shifted so ends are open)
    difference() {
        cube([ow, oh, L], center=true);

        // Make the inner cut slightly longer and offset so it fully opens both ends
        translate([0, 0, 0])
            cube([iw, ih, L + 2*eps], center=true);
    }
}

box_section_rect_tube(outer_width_mm, outer_height_mm, wall_thickness_mm, length_mm, eps_mm);