// Aluminium rectangular box section (rectangular tube)
// 50.8mm x 38.1mm x 3.0mm wall, length configurable

outer_width_mm     = 50.8;  // X
outer_height_mm    = 38.1;  // Y
wall_thickness_mm  = 3.0;   // wall thickness
length_mm          = 100.0; // Z (tube length)
eps_mm             = 0.05;  // small overlap for robust boolean

module rectangular_box_section(ow, oh, t, L, eps=0.05) {
    // Inner dimensions (must remain positive)
    iw = ow - 2*t;
    ih = oh - 2*t;

    assert(iw > 0 && ih > 0, "Wall thickness too large for given outer dimensions.");

    // Build as a 2D ring and linear_extrude to guarantee open ends and visible hollow in end views
    color("Silver")
    linear_extrude(height=L, center=true, convexity=10)
        difference() {
            square([ow, oh], center=true);
            square([iw, ih], center=true);
        }
}

rectangular_box_section(outer_width_mm, outer_height_mm, wall_thickness_mm, length_mm, eps_mm);