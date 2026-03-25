$fn=64;

module rect_box_section(outer_x=12, outer_y=8, wall=1, length=50) {
    inner_x = outer_x - 2*wall;
    inner_y = outer_y - 2*wall;
    difference() {
        cube([outer_x, outer_y, length], center=true);
        cube([inner_x, inner_y, length+0.2], center=true);
    }
}

rect_box_section(12, 8, 1, 50);