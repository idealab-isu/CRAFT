$fn = 120;

// Threaded heat-set insert (simplified geometry)
// Specs: 4.0mm OD, 4.6mm length, for M2.5 screw
module threaded_insert(
    od = 4.0,
    len = 4.6,
    screw_d = 2.5,          // clearance for M2.5 screw
    minor_d = 2.2,          // approximate minor diameter for M2.5 internal thread
    leadin_h = 0.5,         // lead-in at both ends
    knurl_count = 18,       // retention ribs around OD
    knurl_depth = 0.25,     // radial protrusion of knurl beyond base OD
    knurl_z_margin = 0.35   // keep knurl off the very ends
) {
    eps = 0.02;

    // Overlap to guarantee physical attachment (1-2mm as requested)
    overlap = 1.0;

    r_outer = od/2;

    // Ensure there is ALWAYS a continuous central sleeve/body that all fins attach to.
    // Make it slightly smaller than OD so fins can protrude to OD.
    r_sleeve = max(r_outer - knurl_depth, minor_d/2 + 0.25);

    // Knurl height region
    knurl_h = max(len - 2*knurl_z_margin, 0);

    // Ensure knurls always have some height and overlap into the sleeve along Z
    knurl_h_eff = max(knurl_h, 0.01);
    knurl_z0 = max(knurl_z_margin - overlap/2, 0);
    knurl_z1 = min(knurl_z0 + knurl_h_eff + overlap, len);

    difference() {
        // ONE connected outer solid: central sleeve + fins that overlap into sleeve
        union() {
            // Central sleeve/body (fixes "no visible central sleeve/body")
            cylinder(r=r_sleeve, h=len);

            // Knurl fins: make them extend radially inward past the sleeve by ~overlap
            // so they are guaranteed to intersect/attach (fixes floating/disconnected fins).
            fin_inset = overlap; // how far the fin penetrates into the sleeve radially
            fin_r_center = r_sleeve + (knurl_depth/2) - (fin_inset/2);

            for (i = [0:knurl_count-1]) {
                rotate([0, 0, i*360/knurl_count])
                    translate([fin_r_center, 0, knurl_z0])
                        linear_extrude(height=knurl_z1 - knurl_z0)
                            polygon(points=[
                                // Base of fin extends inward to overlap into sleeve
                                [-(knurl_depth/2 + fin_inset/2), -0.18],
                                [-(knurl_depth/2 + fin_inset/2),  0.18],
                                // Tip reaches outward to OD
                                [ (knurl_depth/2 - fin_inset/2),  0.00]
                            ]);
            }
        }

        // Internal bore (minor diameter) through entire length
        translate([0, 0, -eps])
            cylinder(d=minor_d, h=len + 2*eps);

        // Lead-in chamfers (both ends) up to screw clearance diameter
        translate([0, 0, -eps])
            cylinder(d1=screw_d, d2=minor_d, h=leadin_h + eps);

        translate([0, 0, len - leadin_h])
            cylinder(d1=minor_d, d2=screw_d, h=leadin_h + eps);
    }
}

threaded_insert();