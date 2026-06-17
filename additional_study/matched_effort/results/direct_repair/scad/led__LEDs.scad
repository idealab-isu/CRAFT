$fn=64;

// Simple 5mm LED (through-hole) model
// Units: mm

// Parameters
body_d = 5.0;
body_h = 8.0;

lens_h = 2.0;
flange_d = 5.8;
flange_h = 1.0;

lead_d = 0.6;
lead_spacing = 2.54;
lead_len = 12.0;

module led_5mm() {
    union() {
        // Leads (downwards)
        for (sx = [-lead_spacing/2, lead_spacing/2]) {
            translate([sx, 0, -lead_len])
                cylinder(h=lead_len, d=lead_d);
        }

        // Flange at base
        translate([0, 0, 0])
            cylinder(h=flange_h, d=flange_d);

        // Main body
        translate([0, 0, flange_h])
            cylinder(h=body_h - flange_h, d=body_d);

        // Rounded lens top
        translate([0, 0, body_h])
            intersection() {
                // Hemisphere
                sphere(d=body_d);
                // Keep only upper half
                translate([0, 0, 0])
                    cylinder(h=body_d/2, d=body_d);
            }

        // Slight flat on one side (cathode mark)
        difference() {
            // Invisible helper: subtract a small flat from the body
            // Implemented by cutting a thin slice from the side
            // (Done as a separate difference unioned back via intersection trick)
        }
    }
}

// Add a small flat on one side by subtracting from the whole LED
module led_with_flat() {
    difference() {
        led_5mm();
        // Flat cut: remove a slice along +X side
        translate([body_d/2 - 0.6, 0, body_h/2])
            cube([2.0, body_d*1.2, body_h*2], center=true);
    }
}

led_with_flat();