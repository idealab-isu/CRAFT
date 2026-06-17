$fn = 96;

module led_3mm(body_d=3.0, body_h=3.15, flange_d=3.6, flange_h=0.35, dome_h=1.2, lead_d=0.5, lead_len=12, lead_pitch=2.54) {
    // Body (cylindrical + dome)
    color([0.85, 0.1, 0.1, 0.35]) {
        union() {
            // Main cylindrical body
            cylinder(d=body_d, h=body_h);

            // Flange at base
            translate([0,0,0])
                cylinder(d=flange_d, h=flange_h);

            // Dome top (spherical cap approximation)
            translate([0,0,body_h])
                intersection() {
                    sphere(d=body_d);
                    translate([0,0,0])
                        cylinder(d=body_d, h=dome_h);
                }
        }
    }

    // Flat on rim (typical LED cathode flat)
    difference() {
        // no-op wrapper to apply flat cut to the body silhouette
        // (implemented as a subtle cut on the side of the cylinder portion)
        // This is purely visual and small.
        // Cut only the cylindrical portion (not leads).
        color([0,0,0,0]) cube([0,0,0]); // placeholder to keep structure valid
    }

    // Leads
    color([0.75, 0.75, 0.78]) {
        translate([-lead_pitch/2, 0, -lead_len])
            cylinder(d=lead_d, h=lead_len);
        translate([ lead_pitch/2, 0, -lead_len])
            cylinder(d=lead_d, h=lead_len);
    }

    // Cathode flat cut (applied to body)
    // Implemented as a difference on a duplicate body, then unioned back by rendering order.
    // To keep it simple and renderable, we re-render the body with a cut and slight opacity.
    color([0.85, 0.1, 0.1, 0.35]) {
        difference() {
            union() {
                cylinder(d=body_d, h=body_h);
                cylinder(d=flange_d, h=flange_h);
                translate([0,0,body_h])
                    intersection() {
                        sphere(d=body_d);
                        cylinder(d=body_d, h=dome_h);
                    }
            }
            // Flat cut plane
            translate([body_d*0.35, -body_d, -1])
                cube([body_d, body_d*2, body_h + dome_h + 2], center=false);
        }
    }
}

led_3mm();