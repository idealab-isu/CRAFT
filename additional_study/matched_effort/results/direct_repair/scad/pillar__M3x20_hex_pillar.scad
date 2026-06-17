$fn = 96;

thread_d = 3.0;      // nominal thread diameter (mm)
length = 20.0;       // overall length (mm)
outer_d = 6.0;       // fallback pillar diameter since "None" provided (mm)

hole_d = 2.6;        // typical tap drill for M3 (approx)
chamfer = 0.6;

module standoff_pillar(od, h, bore_d) {
    difference() {
        cylinder(d=od, h=h);
        translate([0,0,-0.01])
            cylinder(d=bore_d, h=h+0.02);
        // light chamfers on both ends of the bore
        translate([0,0,-0.01])
            cylinder(d1=bore_d+2*chamfer, d2=bore_d, h=chamfer+0.02);
        translate([0,0,h-chamfer-0.01])
            cylinder(d1=bore_d, d2=bore_d+2*chamfer, h=chamfer+0.02);
    }
}

standoff_pillar(outer_d, length, hole_d);