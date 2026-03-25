$fn=96;

shaft_d = 8.0;
shaft_r = shaft_d/2;
shaft_len = 10.0;

head_d = 14.0;
head_r = head_d/2;
head_h = 4.4;

module dome_head(r_base, h) {
    // Spherical cap: base radius r_base, height h
    R = (r_base*r_base + h*h) / (2*h);
    zc = h - R; // sphere center relative to base plane at z=0
    intersection() {
        translate([0,0,zc]) sphere(r=R);
        cylinder(r=r_base, h=h);
    }
}

module screw() {
    union() {
        translate([0,0,-shaft_len]) cylinder(r=shaft_r, h=shaft_len);
        dome_head(head_r, head_h);
    }
}

screw();