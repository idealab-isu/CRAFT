$fn=64;

// Simple 5mm LED (through-hole) model
// Units: mm

// Parameters
body_d = 5.0;
body_h = 8.7;          // cylindrical body height (excluding dome)
dome_h = 2.3;          // rounded top height
flange_d = 5.8;
flange_h = 1.2;

lead_d = 0.6;
lead_len = 25;

lead_spacing = 2.54;   // typical 0.1" spacing
lead_offset_y = lead_spacing/2;

module led_body() {
    // Main body + flange + dome
    union() {
        // Flange at bottom
        translate([0,0,0])
            cylinder(d=flange_d, h=flange_h);

        // Cylindrical body above flange
        translate([0,0,flange_h])
            cylinder(d=body_d, h=body_h);

        // Dome (spherical cap) on top
        translate([0,0,flange_h + body_h])
            intersection() {
                // Sphere sized to match body diameter
                sphere(d=body_d);
                // Keep only upper cap of height dome_h
                translate([-body_d, -body_d, 0])
                    cube([2*body_d, 2*body_d, dome_h], center=false);
            }

        // Flat on one side (typical LED flat)
        // Subtract a small slice to create a flat
    }
}

module led_body_with_flat() {
    difference() {
        led_body();
        // Create a flat by cutting a plane on one side
        translate([body_d*0.35, 0, -1])
            cube([body_d, body_d*2, flange_h + body_h + dome_h + 2], center=true);
    }
}

module leads() {
    // Two leads: anode (long) and cathode (short)
    // Place them under the flange, centered in X, separated in Y
    union() {
        // Anode (longer)
        translate([0, lead_offset_y, -lead_len])
            cylinder(d=lead_d, h=lead_len + 0.2);

        // Cathode (slightly shorter)
        translate([0, -lead_offset_y, -(lead_len*0.85)])
            cylinder(d=lead_d, h=lead_len*0.85 + 0.2);
    }
}

module led() {
    union() {
        // Body (slightly translucent look via color)
        color([0.9, 0.1, 0.1, 0.6])
            led_body_with_flat();

        // Leads (metal)
        color([0.75, 0.75, 0.78, 1.0])
            leads();
    }
}

led();