// Aluminium rectangular box section 20mm x 20mm x 2mm

outer_width_mm     = 20;   //[10:40:1]
outer_height_mm    = 20;   //[10:40:1]
wall_thickness_mm  = 2;    //[1:6:0.5]
length_mm          = 100;  //[50:300:1]
overlap_mm         = 1;    //[0.5:2:0.5]

module box_section(ow, oh, t, L, overlap=1) {
    // Ensure valid wall thickness
    t_eff = min(t, ow/2 - 0.01, oh/2 - 0.01);

    iw = ow - 2*t_eff;
    ih = oh - 2*t_eff;

    // Inner void is longer so it cleanly cuts through both ends
    inner_L = L + 2*overlap;

    color("Silver")
    difference() {
        cube([ow, oh, L], center=true);
        cube([iw, ih, inner_L], center=true);
    }
}

box_section(outer_width_mm, outer_height_mm, wall_thickness_mm, length_mm, overlap_mm);