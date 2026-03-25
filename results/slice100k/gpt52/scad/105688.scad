$fn=96;

bbox_x = 19.5;
bbox_y = 18.9;
H = 78.5;

OD = min(bbox_x, bbox_y);
Rout = OD/2;

ID = 12.0;
Rin = ID/2;

slit_w = 3.0;

notch_depth = 1.0;
notch_w = 2.2;
notch_z0 = 10;
notch_z1 = 68;
notch_step = 8;

module outer_body() {
    cylinder(h=H, r=Rout, center=true);
}

module inner_bore() {
    cylinder(h=H+0.4, r=Rin, center=true);
}

module axial_slit() {
    translate([0,0,0])
        cube([slit_w, 2*Rout+2, H+0.6], center=true);
}

module relief_notch(zpos, side=1) {
    // side: +1 for +X side, -1 for -X side
    translate([side*(Rin - notch_depth/2), 0, zpos])
        cube([notch_depth, notch_w, notch_w], center=true);
}

module relief_series() {
    for (z = [-H/2 + notch_z0 : notch_step : -H/2 + notch_z1]) {
        relief_notch(z, side=1);
        relief_notch(z + notch_step/2, side=-1);
    }
}

module collar() {
    difference() {
        outer_body();
        inner_bore();
        axial_slit();
        relief_series();
    }
}

collar();