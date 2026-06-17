$fn = 128;

// PTFE heatshrink sleeving (simple hollow tube model)
// Units: mm

// Parameters
length = 50;          // overall length
id = 4.0;             // inner diameter (before/after shrink as desired)
wall = 0.35;          // wall thickness
od = id + 2*wall;     // outer diameter

// Optional: slight end chamfer to mimic cut tubing
chamfer = 0.4;        // set to 0 for square ends

module tube(L, ID, OD, cham=0) {
    difference() {
        // Outer
        if (cham > 0) {
            // Chamfered ends via hull of two cylinders
            hull() {
                translate([0,0,0]) cylinder(h=cham, d=OD - 2*cham);
                translate([0,0,cham]) cylinder(h=L - 2*cham, d=OD);
                translate([0,0,L - cham]) cylinder(h=cham, d=OD - 2*cham);
            }
        } else {
            cylinder(h=L, d=OD);
        }

        // Inner bore (slightly extended to ensure clean subtraction)
        translate([0,0,-0.5]) cylinder(h=L + 1.0, d=ID);
    }
}

tube(length, id, od, chamfer);