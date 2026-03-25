$fn=96;

bbox_x = 10.0;
bbox_y = 23.0;
bbox_z = 6.3;

head_d = 10.0;
head_t = 2.0;

shank_d = 6.3;
shank_len = 15.0;

tip_len = 6.0;
slot_w = 1.2;
slot_depth = tip_len + 0.6;

module shank_and_head() {
    union() {
        translate([0, -bbox_y/2 + head_t/2, 0])
            cylinder(h=head_t, d=head_d, center=true);
        translate([0, -bbox_y/2 + head_t + shank_len/2, 0])
            cylinder(h=shank_len, d=shank_d, center=true);
    }
}

module tip_wedge() {
    translate([0, bbox_y/2 - tip_len/2, 0])
        scale([1, 1, 0.55])
            cylinder(h=tip_len, d=shank_d, center=true);
}

module slot_cut() {
    translate([0, bbox_y/2 - slot_depth/2 + 0.2, 0])
        cube([slot_w, slot_depth, bbox_z + 2], center=true);
}

difference() {
    union() {
        shank_and_head();
        tip_wedge();
    }
    slot_cut();
}