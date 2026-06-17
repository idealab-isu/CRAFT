// Aluminium rectangular box section: 12mm x 8mm x 1mm wall
// One connected solid, hollow via difference()

outer_width_mm     = 12;   //[6:24:0.5]
outer_height_mm    = 8;    //[4:16:0.5]
wall_thickness_mm  = 1;    //[0.5:2:0.1]
length_mm          = 100;  //[20:300:1]

// Small extra length for clean boolean subtraction (prevents coplanar faces)
overcut_mm = 0.2;

module rectangular_box_section(ow, oh, t, L) {
    // Ensure valid inner dimensions
    iw = ow - 2*t;
    ih = oh - 2*t;

    // If wall thickness is too large, clamp to keep a valid hollow
    iw2 = max(iw, 0.01);
    ih2 = max(ih, 0.01);

    color("Silver")
    difference() {
        // Outer tube
        cube([ow, oh, L], center=true);

        // Inner void (slightly longer to guarantee through-cut)
        cube([iw2, ih2, L + 2*overcut_mm], center=true);
    }
}

rectangular_box_section(outer_width_mm, outer_height_mm, wall_thickness_mm, length_mm);