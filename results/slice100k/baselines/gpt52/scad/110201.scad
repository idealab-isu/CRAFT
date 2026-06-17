$fn=64;

L = 48.0;
W = 10.0;
H = 16.0;

t = 2.0;                 // strap thickness (Z)
tab_len = 12.0;          // each end tab length (X)
hole_d = 4.5;            // through-hole diameter
hole_edge_margin = 3.0;  // min edge margin in X from tab end

arch_span = L - 2*tab_len;          // X span of arched center
R = H - t/2;                        // outer radius to reach overall height
r = R - t;                          // inner radius
arch_center_x = 0;
arch_center_z = t/2;

module tab(sign=1){
    x0 = sign*(L/2 - tab_len/2);
    translate([x0, 0, t/2])
        cube([tab_len, W, t], center=true);
}

module arch(){
    translate([arch_center_x, 0, arch_center_z])
    intersection(){
        difference(){
            rotate([90,0,0]) cylinder(h=W, r=R, center=true);
            rotate([90,0,0]) cylinder(h=W+0.2, r=r, center=true);
        }
        translate([0,0,R/2])
            cube([arch_span, W+0.2, R], center=true);
    }
}

module strap_solid(){
    union(){
        arch();
        tab(1);
        tab(-1);
    }
}

module holes(){
    hole_x = L/2 - hole_edge_margin - hole_d/2;
    for (sx=[-1,1]){
        translate([sx*hole_x, 0, 0])
            cylinder(h=t+0.6, d=hole_d, center=true);
    }
}

difference(){
    strap_solid();
    holes();
}