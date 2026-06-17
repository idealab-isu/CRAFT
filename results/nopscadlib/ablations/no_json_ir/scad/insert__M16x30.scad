$fn = 180;

// Threaded heat-set insert: 30mm OD, 25mm long, for 16mm screw (modeled as a clearance bore)
module threaded_insert(od=30, len=25, screw_d=16) {
    eps = 0.25;

    r_outer = od/2;
    bore_d  = screw_d;
    bore_r  = bore_d/2;

    // Small internal entry chamfers (kept within the body)
    chamfer_h = 1.5;
    chamfer_d = 2.0;

    // External straight knurl ribs (subtle, connected, full length)
    rib_count = 36;
    rib_out   = 0.9;   // radial protrusion beyond OD
    rib_w     = 1.2;   // tangential width
    rib_h     = len;

    // Ensure ribs overlap into the main cylinder so the solid is one connected piece
    rib_overlap = 0.6; // amount ribs sink into the OD

    difference() {
        union() {
            // Main body
            cylinder(d=od, h=len, center=false);

            // External ribs: centered in Z at len/2, placed at radius so they overlap into body
            for (i = [0 : rib_count-1]) {
                rotate([0, 0, i * 360 / rib_count])
                    translate([r_outer + rib_out/2 - rib_overlap, 0, len/2])
                        cube([rib_out, rib_w, rib_h], center=true);
            }
        }

        // Through bore
        translate([0, 0, -eps])
            cylinder(d=bore_d, h=len + 2*eps, center=false);

        // Top internal chamfer
        translate([0, 0, len - chamfer_h])
            cylinder(d1=bore_d + chamfer_d, d2=bore_d, h=chamfer_h + eps, center=false);

        // Bottom internal chamfer
        translate([0, 0, -eps])
            cylinder(d1=bore_d, d2=bore_d + chamfer_d, h=chamfer_h + eps, center=false);
    }
}

threaded_insert(od=30, len=25, screw_d=16);