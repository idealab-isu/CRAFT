$fn = 180;

bore_d = 5.0;
od_d = 16.0;
width = 5.0;

flange_d = 18.0;
flange_th = 1.0;

chamfer = 0.35;          // small edge chamfer
race_depth = 0.6;        // shallow groove depth
race_width = 1.2;        // groove width

module chamfered_cylinder(d=10, h=5, c=0.3) {
    c = min(c, h/2, d/4);
    union() {
        cylinder(d=d-2*c, h=h);
        translate([0,0,0]) cylinder(d1=d, d2=d-2*c, h=c);
        translate([0,0,h-c]) cylinder(d1=d-2*c, d2=d, h=c);
    }
}

module bearing_body() {
    union() {
        // main ring
        chamfered_cylinder(d=od_d, h=width, c=chamfer);

        // flange on one side
        translate([0,0,width-flange_th])
            chamfered_cylinder(d=flange_d, h=flange_th, c=min(chamfer, flange_th/2));
    }
}

module race_groove(zpos) {
    // torus-like groove via rotate_extrude of a circle
    translate([0,0,zpos])
        rotate_extrude()
            translate([od_d/2 - race_depth, 0, 0])
                circle(d=race_width);
}

difference() {
    union() {
        bearing_body();
    }

    // bore
    translate([0,0,-0.5])
        cylinder(d=bore_d, h=width + 1.0);

    // shallow race grooves (visual detail)
    race_groove(width*0.30);
    race_groove(width*0.70);
}