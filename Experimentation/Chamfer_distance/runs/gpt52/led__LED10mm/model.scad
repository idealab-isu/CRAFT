$fn = 64;

module led_10mm_through_hole(lens_d=10, lens_h=7, flange_d=11.5, flange_h=1.2, body_d=10, body_h=5, lead_d=0.6, lead_spacing=2.54, lead_len=25) {
    union() {
        // Leads (extend downward)
        for (sx = [-lead_spacing/2, lead_spacing/2]) {
            translate([sx, 0, -(lead_len)]) cylinder(h=lead_len, d=lead_d);
        }

        // Main body + flange + lens
        translate([0,0,0]) union() {
            // Body cylinder
            cylinder(h=body_h, d=body_d);

            // Flange
            translate([0,0,body_h - flange_h]) cylinder(h=flange_h, d=flange_d);

            // Lens: cylinder + dome
            translate([0,0,body_h]) union() {
                cylinder(h=lens_h*0.55, d=lens_d);
                translate([0,0,lens_h*0.55]) intersection() {
                    sphere(d=lens_d);
                    translate([0,0,0]) cylinder(h=lens_h*0.45, d=lens_d);
                }
            }

            // Flat spot (typical LED notch)
            difference() {
                // no-op placeholder to keep structure
                children();
            }
        }
    }
}

// Simple flat spot cut applied to body+lens assembly
module led_10mm_with_flat() {
    lens_d=10;
    lens_h=7;
    flange_d=11.5;
    flange_h=1.2;
    body_d=10;
    body_h=5;
    lead_d=0.6;
    lead_spacing=2.54;
    lead_len=25;

    difference() {
        led_10mm_through_hole(lens_d, lens_h, flange_d, flange_h, body_d, body_h, lead_d, lead_spacing, lead_len);

        // Flat spot cut on one side (along +X)
        translate([body_d/2 - 1.2, 0, 0]) cube([5, 6, body_h + lens_h], center=true);
    }
}

// Center model near origin: set Z such that flange bottom ~ Z=0 and leads extend below
translate([0,0,-0.0]) led_10mm_with_flat();