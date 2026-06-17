$fn = 128;

// PTFE heatshrink sleeving (simple hollow tube model)
// Units: mm

// Parameters
inner_diameter = 4.0;     // ID before shrink (approx)
wall_thickness = 0.35;    // typical thin-wall PTFE heatshrink
length = 60.0;            // sleeve length

// Optional: slight end chamfer for realism
chamfer = 0.6;            // set 0 for square ends

module heatshrink_sleeve(id=inner_diameter, t=wall_thickness, L=length, c=chamfer) {
    od = id + 2*t;

    if (c <= 0) {
        difference() {
            cylinder(h=L, d=od);
            translate([0,0,-0.01]) cylinder(h=L+0.02, d=id);
        }
    } else {
        // Outer with chamfered ends
        difference() {
            union() {
                // middle straight section
                translate([0,0,c]) cylinder(h=max(0, L-2*c), d=od);

                // bottom chamfer
                cylinder(h=c, d1=od-2*c, d2=od);

                // top chamfer
                translate([0,0,L-c]) cylinder(h=c, d1=od, d2=od-2*c);
            }

            // Inner bore with matching chamfer (slightly extended to ensure clean subtraction)
            union() {
                translate([0,0,c]) cylinder(h=max(0, L-2*c), d=id);

                // bottom inner chamfer
                translate([0,0,-0.01]) cylinder(h=c+0.01, d1=max(0.01, id-2*c), d2=id);

                // top inner chamfer
                translate([0,0,L-c]) cylinder(h=c+0.01, d1=id, d2=max(0.01, id-2*c));
            }
        }
    }
}

heatshrink_sleeve();