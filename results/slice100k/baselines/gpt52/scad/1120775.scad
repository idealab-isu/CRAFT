$fn=96;

bbox_x = 11.7;
bbox_y = 6.6;
bbox_z = 7.0;

cyl_d = 6.6;
cyl_h = 7.0;

lug_total_x = bbox_x - cyl_d;
lug_len = lug_total_x/2;
lug_thick_y = 2.2;
lug_h = 3.6;

module drum() {
    cylinder(d=cyl_d, h=cyl_h, center=true);
}

module lug(sign=1) {
    translate([sign*(cyl_d/2 + lug_len/2), 0, 0])
        cube([lug_len, lug_thick_y, lug_h], center=true);
}

union() {
    drum();
    lug(1);
    lug(-1);
}