$fn = 64;

outer_w = 50.8;   // mm
outer_h = 38.1;   // mm
wall    = 3.0;    // mm
length  = 100;    // mm (default extrusion length)

inner_w = outer_w - 2*wall;
inner_h = outer_h - 2*wall;

module box_section_rect(outer_w, outer_h, wall, length) {
    inner_w = outer_w - 2*wall;
    inner_h = outer_h - 2*wall;

    if (inner_w <= 0 || inner_h <= 0) {
        cube([outer_w, outer_h, length], center=true);
    } else {
        difference() {
            cube([outer_w, outer_h, length], center=true);
            cube([inner_w, inner_h, length + 0.2], center=true);
        }
    }
}

box_section_rect(outer_w, outer_h, wall, length);