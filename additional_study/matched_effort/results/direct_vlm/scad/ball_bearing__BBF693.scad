$fn = 128;

bore_d = 3.0;
od_d = 8.0;
width = 3.0;

flange_d = 9.5;
flange_th = 0.6;

ring_chamfer = 0.25;
flange_chamfer = 0.25;

module chamfered_cylinder(d=10, h=5, c=0.3) {
    c = min(c, h/2, d/4);
    union() {
        if (h > 2*c)
            translate([0,0,c]) cylinder(d=d, h=h-2*c);
        cylinder(d1=d-2*c, d2=d, h=c);
        translate([0,0,h-c]) cylinder(d1=d, d2=d-2*c, h=c);
    }
}

difference() {
    union() {
        // Main bearing outer ring
        chamfered_cylinder(d=od_d, h=width, c=ring_chamfer);

        // Flange on one side (at z=0)
        chamfered_cylinder(d=flange_d, h=flange_th, c=flange_chamfer);
    }

    // Bore
    translate([0,0,-0.5]) cylinder(d=bore_d, h=width + flange_th + 1.0);

    // Raceway groove approximation (torus-like cut)
    // Creates a shallow groove around the mid-height of the main ring
    groove_r = 0.55;
    groove_R = (od_d/2 + bore_d/2)/2;
    translate([0,0,flange_th + width/2])
        rotate_extrude()
            translate([groove_R,0,0])
                circle(r=groove_r);
}