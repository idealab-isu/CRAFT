$fn=96;

bbox_xy = 11.7;
bbox_z  = 6.3;

core_d = 6.3;
core_h = bbox_z;

lug_len = (bbox_xy - core_d)/2;
lug_w   = 2.4;
lug_h   = bbox_z;

module core() {
    cylinder(d=core_d, h=core_h, center=true);
}

module lug_x() {
    translate([core_d/2 + lug_len/2, 0, 0])
        cube([lug_len, lug_w, lug_h], center=true);
}

module lug_y() {
    rotate([0,0,90]) lug_x();
}

module hub() {
    union() {
        core();
        lug_x();
        rotate([0,0,180]) lug_x();
        lug_y();
        rotate([0,0,180]) lug_y();
    }
}

hub();