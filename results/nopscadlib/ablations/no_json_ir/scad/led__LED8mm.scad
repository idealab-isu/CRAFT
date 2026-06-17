// 8.0mm THT LED (domed epoxy), 9.2mm body height
// Z=0 at bottom of epoxy body (above leads)

$fn = 160;

// Parameters
led_diameter        = 8.0;   // max body diameter
led_body_height     = 9.2;   // epoxy body height (base to top of dome)

rim_flange_diameter = 9.0;   // flange diameter
rim_flange_height   = 1.0;   // flange thickness

lead_diameter       = 0.5;
lead_spacing        = 2.54;
lead_length         = 15.0;

// Connectivity / robustness (REQUIRED: 1–2mm overlap for guaranteed attachment)
overlap = 1.0;

// Derived
body_r   = led_diameter/2;
flange_r = rim_flange_diameter/2;

// Typical 8mm LED proportions: short straight section + domed lens
cyl_h  = led_body_height * 0.58;     // straight cylindrical portion
dome_h = led_body_height - cyl_h;    // dome height

// Spherical cap radius for cap height dome_h with base radius body_r
// a^2 = 2Rh - h^2  =>  R = (a^2 + h^2)/(2h)
dome_R = (body_r*body_r + dome_h*dome_h) / (2*dome_h);

// Small "cap/disc" features (visual detail)
cap_r = body_r * 0.35;   // small disc radius
cap_h = 0.8;             // disc thickness

// LED epoxy body: cylinder + spherical cap (exact total height = led_body_height)
module led_epoxy() {
    union() {
        // Cylindrical body
        cylinder(h=cyl_h, r=body_r);

        // Spherical cap (base at z=cyl_h, top at z=led_body_height)
        // Sphere center is at z = cyl_h + (dome_h - dome_R)
        translate([0, 0, cyl_h + (dome_h - dome_R)])
            intersection() {
                sphere(r=dome_R);

                // Keep only the cap above the base plane z=cyl_h
                // IMPORTANT: do NOT shift this cutter upward; it can detach the dome.
                // Extend slightly below/above to guarantee overlap with the cylinder.
                translate([0, 0, dome_R - dome_h - overlap])
                    cylinder(h=dome_h + 2*overlap, r=body_r + 0.02);
            }
    }
}

// Rim flange at base (overlaps into epoxy so it's one solid)
module led_rim_flange() {
    translate([0, 0, -overlap])
        cylinder(h=rim_flange_height + overlap, r=flange_r);
}

// Leads (overlap into epoxy body so everything is one connected solid)
module two_leads_pins() {
    for (sx = [-1, 1]) {
        translate([sx*lead_spacing/2, 0, -lead_length])
            cylinder(h=lead_length + overlap, d=lead_diameter, $fn=48);
    }
}

// Attached small top cap/disc (overlap into dome)
module top_cap_disc() {
    translate([0, 0, led_body_height - overlap])
        cylinder(h=cap_h, r=cap_r);
}

// Attached small bottom cap/disc (overlap into epoxy base)
module bottom_cap_disc() {
    translate([0, 0, -cap_h + overlap])
        cylinder(h=cap_h, r=cap_r);
}

// Complete LED (one connected solid)
module led() {
    union() {
        led_epoxy();
        led_rim_flange();
        two_leads_pins();
        top_cap_disc();
        bottom_cap_disc();
    }
}

led();