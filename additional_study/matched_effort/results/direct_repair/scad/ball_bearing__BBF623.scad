$fn=128;

bore_d = 3.0;
od_d = 10.0;
width = 4.0;

flange_d = 11.5;
flange_th = 0.8;

ring_chamfer = 0.35;
flange_chamfer = 0.25;

module chamfered_cylinder(d=10, h=4, c=0.3) {
    c2 = min(c, h/2, d/4);
    union() {
        translate([0,0,c2]) cylinder(d=d, h=h-2*c2);
        cylinder(d1=d-2*c2, d2=d, h=c2);
        translate([0,0,h-c2]) cylinder(d1=d, d2=d-2*c2, h=c2);
    }
}

module flanged_bearing() {
    difference() {
        union() {
            chamfered_cylinder(d=od_d, h=width, c=ring_chamfer);
            translate([0,0,width-flange_th])
                chamfered_cylinder(d=flange_d, h=flange_th, c=flange_chamfer);
        }
        translate([0,0,-0.2]) cylinder(d=bore_d, h=width+0.4);
    }
}

flanged_bearing();