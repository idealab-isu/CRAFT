$fn=18;

head_h = 8;
head_r_base = 12;
head_r_top = 2;

shank_h = 18;
shank_r = 4;

rib_th = 1.2;
rib_r = 6.2;
rib_z1 = 6;
rib_z2 = 12;

tip_h = 2.5;
tip_r = 2.2;

module frustum(h, r1, r2) {
    cylinder(h=h, r1=r1, r2=r2, center=false);
}

module rib(zpos) {
    translate([0,0,zpos - rib_th/2])
        cylinder(h=rib_th, r=rib_r, center=false);
}

module shank() {
    union() {
        cylinder(h=shank_h, r=shank_r, center=false);
        rib(rib_z1);
        rib(rib_z2);
        translate([0,0,shank_h])
            frustum(tip_h, shank_r, tip_r);
    }
}

module head() {
    union() {
        frustum(head_h, head_r_base, head_r_top);
        translate([0,0,head_h])
            sphere(r=head_r_top);
    }
}

union() {
    translate([0,0,0]) head();
    translate([0,0,head_h]) shank();
}