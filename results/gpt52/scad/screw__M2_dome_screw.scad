$fn=96;

module dome_head(d_head=3.5, h_head=1.3) {
    r = d_head/2;
    intersection() {
        translate([0,0,h_head/2]) cylinder(h=h_head, r=r, center=true);
        translate([0,0,0]) sphere(r=r);
    }
}

module screw_shank(d=2.0, L=10.0) {
    translate([0,0,-L/2]) cylinder(h=L, r=d/2, center=true);
}

module dome_head_screw(d_shank=2.0, L=10.0, d_head=3.5, h_head=1.3) {
    union() {
        translate([0,0,-L/2]) cylinder(h=L, r=d_shank/2, center=false);
        translate([0,0,0]) dome_head(d_head=d_head, h_head=h_head);
    }
}

dome_head_screw(d_shank=2.0, L=10.0, d_head=3.5, h_head=1.3);