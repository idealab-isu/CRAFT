$fn=128;

outer_d = 60.0;
outer_d_y = 59.6;
thickness = 11.8;

inner_d = 40.0;

notch_count = 8;
notch_depth = 4.0;
notch_width = 6.0;

module ring_body() {
    difference() {
        scale([1, outer_d_y/outer_d, 1])
            cylinder(d=outer_d, h=thickness, center=true);
        cylinder(d=inner_d, h=thickness+0.4, center=true);
    }
}

module inner_notch(angle_deg) {
    rotate([0,0,angle_deg])
        translate([inner_d/2 - notch_depth/2, 0, 0])
            cube([notch_depth, notch_width, thickness+0.6], center=true);
}

difference() {
    ring_body();
    for (i = [0:notch_count-1]) {
        inner_notch(i*360/notch_count);
    }
}