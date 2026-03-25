$fn=96;

d_shank = 6.0;
L_shank = 10.0;

d_head = 10.5;
h_head = 3.3;

module dome_head(d=d_head, h=h_head){
    intersection(){
        translate([0,0,h/2]) cylinder(d=d, h=h, center=true);
        translate([0,0,0]) sphere(d=d);
    }
}

module screw(){
    union(){
        translate([0,0,-L_shank/2]) cylinder(d=d_shank, h=L_shank, center=true);
        translate([0,0,L_shank/2]) dome_head(d=d_head, h=h_head);
    }
}

screw();