$fn = 64;

module pcb_display_bezel(width=84.5, height=54.5, thickness=4, corner_r=3) {
    // Rounded-rectangle bezel block
    linear_extrude(height=thickness, center=true)
        offset(r=corner_r)
            square([width-2*corner_r, height-2*corner_r], center=true);
}

pcb_display_bezel();