$fn = 160;

module threaded_insert(od=18.0, len=16.0, screw_d=8.0) {

    // Lead-in chamfers (top and bottom) to match reference
    chamfer_h = 2.0;
    chamfer_d2 = 16.0;

    // Bore clearance (threads not modeled)
    bore_d = screw_d + 0.4;

    // External ribs/knurl (vertical)
    rib_count   = 36;
    rib_radial  = 0.6;   // protrusion beyond OD/2
    rib_w       = 0.9;   // tangential width
    overlap     = 0.25;  // ensures ribs intersect body (one connected solid)

    // Ribs only on straight mid-section (avoid chamfers)
    rib_h = max(0.01, len - 2*chamfer_h);
    rib_zc = chamfer_h + rib_h/2;

    union() {
        // Body with through-bore
        difference() {
            union() {
                // Straight mid section
                translate([0, 0, chamfer_h])
                    cylinder(d=od, h=len - 2*chamfer_h);

                // Bottom chamfer
                cylinder(d1=chamfer_d2, d2=od, h=chamfer_h);

                // Top chamfer
                translate([0, 0, len - chamfer_h])
                    cylinder(d1=od, d2=chamfer_d2, h=chamfer_h);
            }

            // Through bore (extended to guarantee cut)
            translate([0, 0, -1])
                cylinder(d=bore_d, h=len + 2);
        }

        // External ribs (connected via overlap into the OD cylinder)
        for (i = [0 : rib_count - 1]) {
            rotate([0, 0, i * 360 / rib_count])
                translate([od/2 + rib_radial/2 - overlap, 0, rib_zc])
                    cube([rib_radial, rib_w, rib_h], center=true);
        }
    }
}

threaded_insert();