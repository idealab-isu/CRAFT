$fn=96;

bbox = [22.0, 22.0, 37.6];

body_xy = 18.0;
body_z  = bbox[2];

tab_w = 10.0;
tab_d = 2.0;
tab_h = 3.0;

side_w = 2.0;
side_d = 8.0;
side_h = 10.0;

bore_d = 10.0;

module main_body() {
    cube([body_xy, body_xy, body_z], center=true);
}

module top_bottom_tabs() {
    for (s = [-1, 1]) {
        translate([0, 0, s*(body_z/2 - tab_h/2)])
            cube([tab_w, tab_d, tab_h], center=true);
    }
}

module left_right_keys() {
    for (s = [-1, 1]) {
        translate([s*(body_xy/2 + side_w/2), 0, 0])
            cube([side_w, side_d, side_h], center=true);
    }
}

module outer_shape() {
    union() {
        main_body();
        top_bottom_tabs();
        left_right_keys();
    }
}

module bore() {
    cylinder(d=bore_d, h=body_z + 0.4, center=true);
}

difference() {
    outer_shape();
    bore();
}