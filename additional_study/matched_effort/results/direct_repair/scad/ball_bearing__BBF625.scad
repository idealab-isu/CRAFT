$fn = 180;

bore_d = 5.0;
od_d = 16.0;
width = 5.0;

flange_d = 18.0;
flange_th = 1.0;

chamfer = 0.4;

module chamfered_cylinder(d=10, h=5, c=0.4) {
    c2 = min(c, h/2, d/4);
    union() {
        translate([0,0,c2]) cylinder(d=d, h=h-2*c2);
        cylinder(h=c2, d1=d-2*c2, d2=d);
        translate([0,0,h-c2]) cylinder(h=c2, d1=d, d2=d-2*c2);
    }
}

difference() {
    union() {
        // Main bearing body
        chamfered_cylinder(d=od_d, h=width, c=chamfer);

        // Flange (on one side)
        translate([0,0,width-flange_th])
            chamfered_cylinder(d=flange_d, h=flange_th, c=min(chamfer, flange_th/2));
    }

    // Bore
    translate([0,0,-0.2])
        cylinder(d=bore_d, h=width+0.4);

    // Slight inner relief to suggest raceway (purely cosmetic)
    translate([0,0,0.6])
        cylinder(d=od_d-2.2, h=width-1.2);
}