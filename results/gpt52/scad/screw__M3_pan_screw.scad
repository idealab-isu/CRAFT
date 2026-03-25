$fn=96;

d_shaft = 3.0;
r_shaft = d_shaft/2;

d_head = 5.4;
r_head = d_head/2;
h_head = 2.0;

L = 10.0;

module pan_head(h=h_head, r=r_head){
    union(){
        cylinder(h=h*0.55, r=r, center=false);
        translate([0,0,h*0.55])
            cylinder(h=h*0.45, r1=r, r2=r*0.78, center=false);
    }
}

module screw_shaft(len=L, r=r_shaft){
    cylinder(h=len, r=r, center=false);
}

module pan_head_screw(){
    union(){
        screw_shaft();
        translate([0,0,L]) pan_head();
    }
}

translate([0,0,-(L + h_head)/2]) pan_head_screw();