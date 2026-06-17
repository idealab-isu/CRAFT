$fn=96;

eps = 0.02;

// Bounding box target: 0.1 x 0.1 x 0.0 mm (flat/plate-like)
D_outer = 0.1;
R_outer = D_outer/2;

t_total = 0.02;          // very thin plate
t_flange = 0.012;        // base thickness
t_boss = t_total - t_flange;

D_boss = 0.06;
R_boss = D_boss/2;

hex_af = 0.022;          // across flats
hex_r = hex_af / sqrt(3);

hex_center_r = 0.018;    // radial placement of hex centers
web_w = 0.010;           // web rib width
web_depth = 0.004;       // recess depth on each face

module disk_base() {
    union() {
        cylinder(h=t_flange, r=R_outer, center=true);
        if (t_boss > 0)
            translate([0,0,(t_flange/2 - t_total/2) + t_boss/2])
                cylinder(h=t_boss, r=R_boss, center=true);
    }
}

module hex_prism(h) {
    cylinder(h=h, r=hex_r, $fn=6, center=true);
}

module hex_cutouts() {
    for (a = [0,120,240]) {
        translate([hex_center_r*cos(a), hex_center_r*sin(a), 0])
            hex_prism(t_total + 2*eps);
    }
}

module web_rib_between(p1, p2, w, h) {
    dx = p2[0]-p1[0];
    dy = p2[1]-p1[1];
    len = sqrt(dx*dx + dy*dy);
    ang = atan2(dy, dx);
    translate([(p1[0]+p2[0])/2, (p1[1]+p2[1])/2, 0])
        rotate([0,0,ang])
            cube([len, w, h], center=true);
}

module face_web_recess(zsign=1) {
    zc = zsign*(t_total/2 - web_depth/2 + eps/2);
    p0 = [hex_center_r*cos(0),   hex_center_r*sin(0)];
    p1 = [hex_center_r*cos(120), hex_center_r*sin(120)];
    p2 = [hex_center_r*cos(240), hex_center_r*sin(240)];
    translate([0,0,zc]) {
        union() {
            web_rib_between(p0, p1, web_w, web_depth + eps);
            web_rib_between(p1, p2, web_w, web_depth + eps);
            web_rib_between(p2, p0, web_w, web_depth + eps);
            cylinder(h=web_depth + eps, r=0.010, center=true);
        }
    }
}

difference() {
    disk_base();
    hex_cutouts();
    face_web_recess(1);
    face_web_recess(-1);
}