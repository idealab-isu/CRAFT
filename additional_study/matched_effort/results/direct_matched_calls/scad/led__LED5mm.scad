$fn = 96;

module led_5mm_tht(body_d=5.0, body_h=5.9, flange_d=5.8, flange_h=1.0,
                   dome_h=2.2, lead_d=0.5, lead_pitch=2.54,
                   lead_len=25.0, standoff=0.2) {

    // Body: cylindrical can + flange + domed top
    color([0.85, 0.1, 0.1, 0.85])
    union() {
        // Main cylindrical body
        translate([0,0,flange_h])
            cylinder(d=body_d, h=body_h - flange_h);

        // Flange at base
        cylinder(d=flange_d, h=flange_h);

        // Dome (spherical cap approximation)
        translate([0,0,body_h])
            intersection() {
                sphere(d=body_d);
                translate([0,0,0])
                    cylinder(d=body_d, h=dome_h);
            }
    }

    // Flat on rim (typical LED cathode flat)
    color([0.85, 0.1, 0.1, 0.85])
    difference() {
        // nothing; implemented by subtracting from a duplicate body shell
        // Create a thin "cut" that removes a flat from the side
        // (Subtract from the whole body union by re-rendering it here)
        // We'll do it by subtracting from a union of the same body.
        // To keep code simple, re-create body and subtract a box.
        union() {
            translate([0,0,flange_h])
                cylinder(d=body_d, h=body_h - flange_h);
            cylinder(d=flange_d, h=flange_h);
            translate([0,0,body_h])
                intersection() {
                    sphere(d=body_d);
                    cylinder(d=body_d, h=dome_h);
                }
        }
        // Flat cut
        translate([body_d*0.35, -body_d, -1])
            cube([body_d, body_d*2, body_h + dome_h + 2], center=false);
    }

    // Leads
    color([0.75, 0.75, 0.75])
    union() {
        // Anode (longer)
        translate([ lead_pitch/2, 0, -lead_len])
            cylinder(d=lead_d, h=lead_len + standoff);

        // Cathode (shorter)
        translate([-lead_pitch/2, 0, -lead_len*0.85])
            cylinder(d=lead_d, h=lead_len*0.85 + standoff);
    }
}

// Render
led_5mm_tht();