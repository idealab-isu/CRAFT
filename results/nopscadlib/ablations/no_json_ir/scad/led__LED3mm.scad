$fn = 120;

// 3.0mm THT LED, 3.15mm body height (lens only), with dome and connected leads.
// Z=0 at bottom of lens body; leads extend downward (negative Z).

module led_3mm_tht(body_d=3.0, body_h=3.15) {

    // Lens profile (typical 3mm LED): cylindrical section + rounded dome
    cyl_h      = body_h * 0.62;                 // cylindrical portion of lens
    dome_h     = body_h - cyl_h;                // dome portion height
    dome_r     = body_d/2;

    // Rim/flange near base (typical LED collar)
    flange_h   = 0.45;
    flange_d   = 3.6;

    // Leads (kept connected to body with a small overlap)
    lead_d     = 0.55;
    lead_len   = 8.0;
    lead_pitch = 1.0;                           // center-to-center spacing
    overlap    = 0.15;

    union() {
        // Lens body: cylinder + spherical cap (intersection to form a dome)
        union() {
            cylinder(h=cyl_h, d=body_d);

            translate([0,0,cyl_h])
                intersection() {
                    // Sphere centered so its "equator" is at z=cyl_h
                    sphere(r=dome_r);
                    // Keep only the upper cap of height dome_h
                    translate([-body_d, -body_d, 0])
                        cube([2*body_d, 2*body_d, dome_h]);
                }
        }

        // Flange at base (slight overlap into lens to ensure connectivity)
        translate([0,0,0])
            cylinder(h=flange_h, d=flange_d);

        // Two leads, connected into the body by overlap
        for (x = [-lead_pitch/2, lead_pitch/2]) {
            translate([x, 0, -lead_len])
                cylinder(h=lead_len + overlap, d=lead_d);
        }
    }
}

led_3mm_tht();