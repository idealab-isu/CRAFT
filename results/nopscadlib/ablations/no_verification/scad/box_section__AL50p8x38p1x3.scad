// Aluminium rectangular hollow section (RHS)
// 50.8mm x 38.1mm x 3.0mm wall thickness

outer_width    = 50.8;  // X
outer_height   = 38.1;  // Y
wall_thickness = 3.0;   // wall
length         = 200;   // Z (extrusion length)
center_model   = true;

eps = 0.02;

module rhs_box_section(ow, oh, t, L, centered=true) {
    iw = ow - 2*t;
    ih = oh - 2*t;

    assert(iw > 0 && ih > 0, "Wall thickness too large for given outer dimensions.");

    // Make the tube open-ended so top/bottom views show the hollow interior.
    // Inner void is slightly longer to guarantee a clean through-cut.
    color("Silver")
    difference() {
        cube([ow, oh, L], center=centered);
        cube([iw, ih, L + 2*eps], center=centered);
    }
}

rhs_box_section(outer_width, outer_height, wall_thickness, length, center_model);