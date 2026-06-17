$fn=96;

module dome_head(d_shank=3.0, d_head=5.7, h_head=1.65) {
    union() {
        cylinder(h=h_head*0.55, d=d_head);
        translate([0,0,h_head*0.55])
            scale([1,1,(h_head*0.45)/(d_head/2)])
                sphere(d=d_head);
    }
}

module screw(d_shank=3.0, d_head=5.7, h_head=1.65, L=10.0) {
    union() {
        translate([0,0,-L])
            cylinder(h=L, d=d_shank);
        dome_head(d_shank=d_shank, d_head=d_head, h_head=h_head);
    }
}

screw(d_shank=3.0, d_head=5.7, h_head=1.65, L=10.0);