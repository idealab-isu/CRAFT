$fn = 128;

module threaded_insert(
    od = 8.2,            // outer diameter
    len = 6.3,           // overall length
    screw_d = 4.0,       // for 4.0mm screw (informational)
    bore_d = 4.0,        // through-bore diameter
    chamfer_h = 0.6,     // lead-in chamfer height (each end)
    chamfer_d = 6.8,     // end-face outer diameter at chamfer
    knurl_count = 18,    // number of axial knurl ribs
    knurl_depth = 0.45,  // radial protrusion of ribs
    knurl_w = 0.9,       // rib tangential width
    knurl_z_margin = 0.7,// keep ribs away from chamfers
    overlap = 0.20       // overlap to guarantee manifold union
) {
    r = od/2;
    h = len;

    // Clamp to valid ranges
    chamfer_h2 = min(chamfer_h, h/2 - 0.01);
    knurl_h = max(0.01, h - 2*(chamfer_h2 + knurl_z_margin));
    knurl_z0 = (h - knurl_h)/2; // distance from center to knurl block center

    difference() {
        union() {
            // Main body
            cylinder(d=od, h=h, center=true);

            // Outer end chamfers (reduce OD at ends)
            translate([0, 0,  h/2 - chamfer_h2/2])
                cylinder(d1=od, d2=chamfer_d, h=chamfer_h2 + overlap, center=true);
            translate([0, 0, -h/2 + chamfer_h2/2])
                cylinder(d1=chamfer_d, d2=od, h=chamfer_h2 + overlap, center=true);

            // Axial knurl ribs (protrude outward, overlap into body)
            for (i = [0:knurl_count-1]) {
                rotate([0, 0, i*360/knurl_count])
                    translate([r + knurl_depth/2 - overlap, 0, 0])
                        cube([knurl_depth + 2*overlap, knurl_w, knurl_h], center=true);
            }
        }

        // Central through-hole
        cylinder(d=bore_d, h=h + 2*overlap, center=true);

        // Small entry reliefs (internal lead-in)
        translate([0, 0,  h/2 - chamfer_h2/2])
            cylinder(d1=bore_d + 0.8, d2=bore_d, h=chamfer_h2 + overlap, center=true);
        translate([0, 0, -h/2 + chamfer_h2/2])
            cylinder(d1=bore_d, d2=bore_d + 0.8, h=chamfer_h2 + overlap, center=true);
    }
}

threaded_insert();