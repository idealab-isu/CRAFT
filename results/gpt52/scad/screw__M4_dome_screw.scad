$fn=96;

d_shaft = 4.0;
r_shaft = d_shaft/2;

d_head = 7.6;
r_head = d_head/2;
h_head = 2.2;

L = 10.0;

module dome_head(h=h_head, r=r_head){
    union(){
        cylinder(h=h*0.55, r=r, center=false);
        translate([0,0,h*0.55])
            scale([1,1,(h*0.45)/r])
                sphere(r=r);
    }
}

module screw_body(){
    union(){
        cylinder(h=L, r=r_shaft, center=false);
        translate([0,0,L])
            dome_head();
    }
}

translate([0,0,-L/2])
    screw_body();