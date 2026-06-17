$fn = 128;

// PTFE heatshrink sleeving (simple hollow tube model)
// Units: mm

// Parameters
length = 50;          // overall length of sleeving
id = 4.0;             // inner diameter (before/after shrink as modeled)
wall = 0.5;           // wall thickness
od = id + 2*wall;     // outer diameter

// Optional: slight end chamfer to mimic cut tubing
chamfer = 0.3;        // set to 0 for square ends

module tube(L, ID, OD, chamfer=0) {
    difference() {
        // Outer body with optional chamfer
        if (chamfer > 0) {
            hull() {
                translate([0,0,0]) cylinder(h=0.01, d=OD - 2*chamfer);
                translate([0,0,chamfer]) cylinder(h=L - 2*chamfer, d=OD);
                translate([0,0,L-0.01]) cylinder(h=0.01, d=OD - 2*chamfer);
            }
        } else {
            cylinder(h=L, d=OD);
        }

        // Inner bore (slightly extended to ensure clean subtraction)
        translate([0,0,-0.5]) cylinder(h=L+1.0, d=ID);
    }
}

tube(length, id, od, chamfer);