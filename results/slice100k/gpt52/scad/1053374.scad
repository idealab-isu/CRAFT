$fn=96;

bbox_x = 19.6;
bbox_y = 12.4;
bbox_z = 12.4;

lug_d = 12.4;
lug_r = lug_d/2;
lug_h = 12.4;

hole_d = 4.2;

arm_th = 4.0;
arm_w  = 8.0;

pad_len = 5.2;
pad_w   = 10.0;
pad_th  = 4.0;

arm_start_x = lug_r - 0.2;
arm_end_x   = bbox_x/2 - pad_len;

notch_r = 3.2;
notch_depth = 6.0;
notch_center_x = arm_start_x + 3.8;

pad_angle = 20;

module lug() {
    difference() {
        cylinder(h=lug_h, r=lug_r, center=true);
        cylinder(h=lug_h+0.6, r=hole_d/2, center=true);
    }
}

module arm_body() {
    translate([(arm_start_x + arm_end_x)/2, 0, 0])
        cube([arm_end_x - arm_start_x, arm_w, arm_th], center=true);
}

module end_pad() {
    translate([bbox_x/2 - pad_len/2, 0, 0])
        rotate([0, pad_angle, 0])
            cube([pad_len, pad_w, pad_th], center=true);
}

module u_notch() {
    translate([notch_center_x, 0, 0])
        rotate([90, 0, 0])
            cylinder(h=notch_depth, r=notch_r, center=true);
}

difference() {
    union() {
        lug();
        arm_body();
        end_pad();
    }
    translate([0, 0, 0])
        u_notch();
}