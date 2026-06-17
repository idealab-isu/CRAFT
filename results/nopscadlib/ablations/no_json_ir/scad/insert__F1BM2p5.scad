$fn = 120;

module threaded_insert(
    od = 5.8,
    h  = 4.6,

    // for M2.5 heat-set inserts, the internal minor/clearance is typically ~2.0–2.2mm
    // keep parameter name but default to a more realistic value
    screw_d = 2.1,

    // end lead-ins
    chamfer_h = 0.45,
    chamfer_d = 4.8,

    // knurl/ribs
    ribs_n = 6,
    rib_radial = 0.45,     // protrusion beyond OD/2
    rib_tangential = 0.9,  // rib width around circumference

    // small end collars (as seen in reference views)
    collar_h = 0.55,
    collar_radial = 0.25   // protrusion beyond OD/2
) {
    r_body = od/2;

    // ribs: make them tangentially narrow and radially protruding, centered on body
    rib_depth = rib_radial + 0.12;                 // ensure intersection
    rib_width = rib_tangential;
    rib_zc = h/2;
    rib_xc = r_body + rib_radial/2 - 0.06;         // overlap into body

    // collars: thin rings at both ends, connected by overlap
    collar_d = od + 2*collar_radial;
    eps = 0.02;

    difference() {
        union() {
            // main body
            cylinder(d=od, h=h);

            // ribs/knurl
            for (i = [0:ribs_n-1]) {
                rotate([0,0,i*360/ribs_n])
                    translate([rib_xc, 0, rib_zc])
                        cube([rib_depth, rib_width, h], center=true);
            }

            // top collar (overlap into body)
            translate([0,0,h - collar_h + eps])
                cylinder(d=collar_d, h=collar_h);

            // bottom collar (overlap into body)
            translate([0,0,-eps])
                cylinder(d=collar_d, h=collar_h);

            // top lead-in chamfer (overlap)
            translate([0,0,h - eps])
                cylinder(d1=od, d2=chamfer_d, h=chamfer_h + eps);

            // bottom lead-in chamfer (overlap)
            translate([0,0,-chamfer_h])
                cylinder(d1=chamfer_d, d2=od, h=chamfer_h + eps);
        }

        // internal hole
        translate([0,0,-0.5])
            cylinder(d=screw_d, h=h + 1.0);
    }
}

threaded_insert();