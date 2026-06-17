$fn=96;

bbox_x = 10.0;
bbox_y = 18.0;
bbox_z = 6.3;

head_d = 10.0;
head_t = 2.2;

shank_d = 6.3;
shank_len = 10.0;

prong_len = 5.8;
prong_th = 2.2;
prong_w = 2.6;
gap = 1.2;
spread = 1.6;

y_min = -bbox_y/2;
y_max =  bbox_y/2;

module head_flange() {
    translate([0, y_min + head_t/2, 0])
        rotate([90,0,0])
            cylinder(d=head_d, h=head_t, center=true);
}

module shank() {
    translate([0, y_min + head_t + shank_len/2, 0])
        rotate([90,0,0])
            cylinder(d=shank_d, h=shank_len, center=true);
}

module prong_body() {
    hull() {
        translate([0,0,0]) cube([prong_w, 0.2, prong_th], center=true);
        translate([0,prong_len,0]) cube([prong_w*0.55, 0.2, prong_th*0.75], center=true);
    }
}

module prong_cut_tip() {
    translate([0, prong_len*0.72, 0])
        rotate([0,0,35])
            cube([prong_w*2.2, prong_len*0.9, prong_th*2.2], center=true);
}

module prong(side=1) {
    translate([side*(gap/2 + prong_w/2), 0, 0])
        rotate([0,0,side*spread*10])
            difference() {
                prong_body();
                prong_cut_tip();
            }
}

module fork_prongs() {
    y0 = y_min + head_t + shank_len;
    translate([0, y0, 0]) {
        prong(1);
        prong(-1);
        translate([0, prong_len*0.35, 0])
            cube([gap*0.9, prong_len*0.7, prong_th*0.9], center=true);
    }
}

module center_slot() {
    y0 = y_min + head_t + shank_len;
    translate([0, y0 + prong_len*0.55, 0])
        cube([gap, prong_len*1.2, prong_th*1.4], center=true);
}

difference() {
    union() {
        head_flange();
        shank();
        fork_prongs();
    }
    center_slot();
}