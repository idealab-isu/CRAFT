$fn=64;

module box_section_rect(outer_x=38.1, outer_y=25.4, wall=1.6, length=100) {
    inner_x = outer_x - 2*wall;
    inner_y = outer_y - 2*wall;
    difference() {
        cube([outer_x, outer_y, length], center=true);
        cube([inner_x, inner_y, length+0.2], center=true);
    }
}

box_section_rect(38.1, 25.4, 1.6, 100);