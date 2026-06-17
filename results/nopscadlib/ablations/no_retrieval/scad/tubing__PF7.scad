// PTFE Tubing (hollow cylinder with optional end chamfers)
// Fixed: robust, non-empty geometry; chamfers implemented as a single connected solid

// Parameters
tube_length = 500; //[250:1000:1]
tube_od = 4;       //[2:8:0.1]
tube_id = 2.5;     //[1.25:5:0.1]
end_face_flatness = 0; //[0:0.5:0.05]  // kept for compatibility (not used)
end_chamfer = 0.5;     //[0:2:0.1]
overlap = 1;           //[0.5:2:0.1]

// Quality
$fn = 128;

// Guards
od = max(tube_od, 0.01);
id = min(max(tube_id, 0.0), od - 0.02);
L  = max(tube_length, 0.01);
ov = max(overlap, 0.01);

// Chamfer limited so it can't invert geometry
ch = min(max(end_chamfer, 0.0), min(L/2 - 0.001, (od - id)/2 - 0.001));
ch = max(ch, 0);

// Main tube
module ptfe_tube() {
    difference() {
        // Outer body with optional end chamfers (single connected solid)
        if (ch > 0) {
            union() {
                // Middle straight section
                cylinder(h = L - 2*ch, r = od/2, center = true);

                // End frustums (chamfers)
                for (s = [-1, 1]) {
                    translate([0, 0, s*((L - ch)/2)])
                        cylinder(h = ch, r1 = od/2, r2 = od/2 - ch, center = true);
                }
            }
        } else {
            cylinder(h = L, r = od/2, center = true);
        }

        // Inner bore (slightly longer to guarantee through-hole)
        cylinder(h = L + 2*ov, r = id/2, center = true);
    }
}

// Final output
ptfe_tube();