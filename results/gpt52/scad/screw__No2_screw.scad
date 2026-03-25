$fn=96;

d_shaft = 2.2;
r_shaft = d_shaft/2;

d_head = 4.2;
r_head = d_head/2;
h_head = 1.7;

L_total = 10;
h_shaft = L_total - h_head;

module pan_head(h=h_head, r=r_head){
    union(){
        cylinder(h=h*0.55, r=r);
        translate([0,0,h*0.55])
            cylinder(h=h*0.45, r1=r, r2=r*0.78);
    }
}

module screw(){
    union(){
        translate([0,0,-L_total/2])
            cylinder(h=h_shaft, r=r_shaft);
        translate([0,0,-L_total/2 + h_shaft])
            pan_head();
    }
}

screw();