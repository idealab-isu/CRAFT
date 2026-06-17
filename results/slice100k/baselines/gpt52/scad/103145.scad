$fn=128;

od_x = 60.0;
od_y = 60.6;
h = 11.8;

od = min(od_x, od_y);
outer_r = od/2;

id = 40.0;
inner_r = id/2;

notch_count = 8;
notch_depth = 3.0;
notch_width = 6.0;

tab_count = 2;
tab_w = 6.0;
tab_t = 3.0;
tab_h = h;
tab_angle_span = 18;

module base_ring() {
    difference() {
        cylinder(h=h, r=outer_r, center=true);
        cylinder(h=h+0.4, r=inner_r, center=true);
    }
}

module inner_notches() {
    for (i = [0:notch_count-1]) {
        rotate([0,0, i*360/notch_count])
            translate([inner_r - notch_depth/2, 0, 0])
                cube([notch_depth, notch_width, h+0.6], center=true);
    }
}

module outer_tabs() {
    for (j = [0:tab_count-1]) {
        rotate([0,0, (j-(tab_count-1)/2)*tab_angle_span])
            translate([outer_r + tab_t/2, 0, 0])
                cube([tab_t, tab_w, tab_h], center=true);
    }
}

difference() {
    union() {
        base_ring();
        outer_tabs();
    }
    inner_notches();
}