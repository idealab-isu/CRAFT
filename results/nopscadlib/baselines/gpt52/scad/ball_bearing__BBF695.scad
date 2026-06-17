$fn=96;

bore_d = 5.0;
od_d = 13.0;
width = 4.0;

flange_d = 15.0;
flange_th = 1.0;

ring_chamfer = 0.3;
flange_chamfer = 0.3;

module chamfered_cylinder(d=10, h=5, c=0.3) {
    c2 = min(c, h/2, d/4);
    union() {
        translate([0,0,c2]) cylinder(d=d, h=h-2*c2);
        cylinder(h=c2, d1=d-2*c2, d2=d);
        translate([0,0,h-c2]) cylinder(h=c2, d1=d, d2=d-2*c2);
    }
}

module bearing_body() {
    union() {
        chamfered_cylinder(d=od_d, h=width, c=ring_chamfer);
        translate([0,0,width/2 - flange_th/2])
            chamfered_cylinder(d=flange_d, h=flange_th, c=flange_chamfer);
    }
}

module bearing() {
    difference() {
        translate([0,0,-width/2]) bearing_body();
        translate([0,0,-width/2 - 0.2]) cylinder(d=bore_d, h=width+0.4);
    }
}

bearing();