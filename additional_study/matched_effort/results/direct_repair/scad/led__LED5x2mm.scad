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
lead_len = 25.0;
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
                // Keep only upper cap
                translate([-body_d, -body_d, 0])
                    cube([2*body_d, 2*body_d, dome_h]);
            }
    }
}

module led_leads() {
    // Two leads extending downward from bottom of flange
    // One longer (anode), one shorter (cathode)
    anode_extra = 3.0;
    cathode_extra = 0.0;

    union() {
        // Anode (longer)
        translate([0, lead_offset_y, -lead_len - anode_extra])
            cylinder(d=lead_d, h=lead_len + anode_extra);

        // Cathode (shorter)
        translate([0, -lead_offset_y, -lead_len - cathode_extra])
            cylinder(d=lead_d, h=lead_len + cathode_extra);
    }
}

module led() {
    // Slight flat on one side of body to indicate cathode
    flat_depth = 0.6;

    union() {
        // Body with flat
        difference() {
            led_body();
            // Cut a flat along one side
            translate([body_d/2 - flat_depth, -body_d, -1])
                cube([body_d, 2*body_d, flange_h + body_h + dome_h + 2]);
        }

        // Leads
        color([0.75,0.75,0.75]) led_leads();
    }
}

// Render
color([1.0, 0.1, 0.1, 0.35]) led();