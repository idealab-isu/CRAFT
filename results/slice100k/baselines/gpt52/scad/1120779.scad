$fn=64;

bbox_xy = 11.7;
bbox_z  = 6.3;

core_d = 6.3;
core_h = bbox_z;

tab_len = (bbox_xy - core_d)/2;
tab_w   = 3.0;
tab_h   = core_h;

module tab_x() {
    translate([core_d/2, -tab_w/2, -tab_h/2])
        cube([tab_len, tab_w, tab_h], center=false);
}

module tab_y() {
    translate([-tab_w/2, core_d/2, -tab_h/2])
        cube([tab_w, tab_len, tab_h], center=false);
}

module hub() {
    union() {
        cylinder(d=core_d, h=core_h, center=true);
        tab_x();
        mirror([1,0,0]) tab_x();
        tab_y();
        mirror([0,1,0]) tab_y();
    }
}

hub();