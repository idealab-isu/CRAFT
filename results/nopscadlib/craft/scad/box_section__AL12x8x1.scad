// Aluminium rectangular box section 12mm x 8mm x 1mm (open-ended tube)

// Parameters
outer_width_mm     = 12;   //[6:24:0.5]
outer_height_mm    = 8;    //[4:16:0.5]
wall_thickness_mm  = 1;    //[0.5:2:0.1]
length_mm          = 100;  //[20:400:1]
overlap_mm         = 0.8;  //[0.1:2:0.1]

// Derived (guard against invalid wall thickness)
inner_width_mm  = max(outer_width_mm  - 2*wall_thickness_mm, 0.01);
inner_height_mm = max(outer_height_mm - 2*wall_thickness_mm, 0.01);

module box_section_rect_tube() {
    // Ensure the inner cut is slightly longer so the tube is clearly open-ended
    inner_cut_len = length_mm + 2*overlap_mm;

    color("Silver")
    difference() {
        cube([outer_width_mm, outer_height_mm, length_mm], center=true);
        cube([inner_width_mm, inner_height_mm, inner_cut_len], center=true);
    }
}

box_section_rect_tube();