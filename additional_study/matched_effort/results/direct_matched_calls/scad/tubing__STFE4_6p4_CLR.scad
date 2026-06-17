$fn = 128;

// PTFE heatshrink sleeving (simple hollow tube model)
// Units: mm

// Parameters
length = 50;          // overall length
id = 4.0;             // inner diameter
wall = 0.5;           // wall thickness
od = id + 2*wall;     // outer diameter

// Optional: slight end chamfer to mimic cut tubing
chamfer = 0.3;        // set to 0 for square ends

module tube(L, ID, OD, chamfer=0) {
    r_in = ID/2;
    r_out = OD/2;

    difference() {
        // Outer body with optional chamfer
        if (chamfer > 0) {
            minkowski() {
                cylinder(h = max(0.01, L - 2*chamfer), r = r_out - chamfer, center = false);
                cylinder(h = chamfer, r = chamfer, center = false);
            }
        } else {
            cylinder(h = L, r = r_out, center = false);
        }

        // Inner bore (extend slightly to ensure clean subtraction)
        translate([0,0,-0.5])
            cylinder(h = L + 1.0, r = r_in, center = false);
    }
}

tube(length, id, od, chamfer);