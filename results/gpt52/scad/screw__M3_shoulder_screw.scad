$fn=96;

d_shaft = 4.0;
r_shaft = d_shaft/2;
d_head  = 7.0;
r_head  = d_head/2;
h_head  = 2.4;
len_total = 10.0;
h_shaft = len_total - h_head;

module screw_shaft(d=4.0, h=7.6) {
    cylinder(d=d, h=h, center=false);
}

module screw_head(d=7.0, h=2.4) {
    cylinder(d=d, h=h, center=false);
}

module screw(d_shaft=4.0, d_head=7.0, h_head=2.4, len_total=10.0) {
    h_shaft = len_total - h_head;
    translate([0,0,-len_total/2])
    union() {
        screw_shaft(d=d_shaft, h=h_shaft);
        translate([0,0,h_shaft]) screw_head(d=d_head, h=h_head);
    }
}

screw(d_shaft=d_shaft, d_head=d_head, h_head=h_head, len_total=len_total);