$fn=96;

module dome_head(d_shank=5.0, d_head=9.5, h_head=2.75){
    union(){
        cylinder(d=d_head, h=h_head*0.55, center=false);
        translate([0,0,h_head*0.55])
            scale([1,1,(h_head*0.45)/(d_head/2)])
                sphere(d=d_head);
        cylinder(d=d_shank, h=h_head, center=false);
    }
}

module screw(d_shank=5.0, d_head=9.5, h_head=2.75, L=10.0){
    union(){
        translate([0,0,-L/2])
            cylinder(d=d_shank, h=L, center=false);
        translate([0,0,L/2 - h_head])
            dome_head(d_shank=d_shank, d_head=d_head, h_head=h_head);
    }
}

screw(d_shank=5.0, d_head=9.5, h_head=2.75, L=10.0);