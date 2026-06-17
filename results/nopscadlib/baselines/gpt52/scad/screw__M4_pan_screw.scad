$fn=96;

d_shaft = 4.0;
r_shaft = d_shaft/2;

d_head = 7.8;
r_head = d_head/2;
h_head = 3.3;

L_total = 10.0;
L_shaft = L_total - h_head;

module pan_head(h=h_head, r=r_head) {
    union() {
        cylinder(h=h*0.55, r=r);
        translate([0,0,h*0.55])
            sphere(r=r);
    }
}

module screw() {
    union() {
        translate([0,0,-L_total/2])
            cylinder(h=L_shaft, r=r_shaft);
        translate([0,0,-L_total/2 + L_shaft])
            intersection() {
                pan_head(h=h_head, r=r_head);
                cylinder(h=h_head, r=r_head);
            }
    }
}

screw();