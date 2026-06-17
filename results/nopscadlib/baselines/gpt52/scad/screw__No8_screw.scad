$fn=96;

d_shank = 4.2;
r_shank = d_shank/2;

d_head = 8.2;
r_head = d_head/2;

h_head = 3.05;
L_total = 10;
h_shank = L_total - h_head;

module pan_head(h=h_head, r=r_head){
    union(){
        cylinder(h=h*0.55, r=r, center=false);
        translate([0,0,h*0.55])
            scale([1,1,0.45])
                sphere(r=r);
    }
}

module screw(){
    union(){
        translate([0,0,-L_total/2])
            cylinder(h=h_shank, r=r_shank, center=false);
        translate([0,0,-L_total/2 + h_shank])
            pan_head(h=h_head, r=r_head);
    }
}

screw();