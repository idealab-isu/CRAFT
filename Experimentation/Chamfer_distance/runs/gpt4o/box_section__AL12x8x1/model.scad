$fn = 64;

module box_section_tube() {
    outer_length = 12;
    outer_width = 8;
    wall_thickness = 1;
    fillet_radius = 0.5;

    // Outer box
    outer_box = offset(r = fillet_radius)
        offset(delta = -fillet_radius)
        square([outer_length, outer_width], center = true);

    // Inner box
    inner_length = outer_length - 2 * wall_thickness;
    inner_width = outer_width - 2 * wall_thickness;
    inner_box = offset(r = fillet_radius)
        offset(delta = -fillet_radius)
        square([inner_length, inner_width], center = true);

    // Extrude and create the tube
    difference() {
        linear_extrude(height = 50, center = true) {
            outer_box;
        }
        translate([0, 0, -25])
            linear_extrude(height = 50, center = true) {
                inner_box;
            }
    }
}

box_section_tube();