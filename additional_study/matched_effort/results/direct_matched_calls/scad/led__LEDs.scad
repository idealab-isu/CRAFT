$fn=64;

// Simple 5mm LED (through-hole) model
// Units: mm

// Parameters
body_d = 5.0;
body_h = 7.0;
lens_h = 2.0;

flange_d = 5.8;
flange_h = 1.0;

lead_d = 0.6;
lead_len = 25.0;
lead_spacing = 2.54;

anode_extra = 2.0; // anode slightly longer

module led_body() {
    // Main epoxy body + lens dome + flange
    union() {
        // Flange at bottom
        translate([0,0,0])
            cylinder(d=flange_d, h=flange_h);

        // Cylindrical body above flange
        translate([0,0,flange_h])
            cylinder(d=body_d, h=body_h);

        // Rounded lens top (spherical cap)
        translate([0,0,flange_h + body_h])
            intersection() {
                sphere(d=body_d);
                translate([0,0,0])
                    cylinder(d=body_d, h=lens_h);
            }

        // Flat on one side (cathode mark)
        // Subtract a small slice to create a flat
    }
}

module led() {
    difference() {
        // Body
        color([0.85, 0.1, 0.1, 0.35]) // translucent red
            led_body();

        // Flat side cut
        translate([body_d*0.35, 0, flange_h + body_h*0.35])
            rotate([0,90,0])
                cylinder(d=body_d*0.9, h=body_d, center=true);
    }

    // Leads
    // Cathode (shorter) on left, Anode (longer) on right
    color([0.75,0.75,0.78])
    union() {
        // Cathode
        translate([-lead_spacing/2, 0, -lead_len])
            cylinder(d=lead_d, h=lead_len);

        // Anode
        translate([ lead_spacing/2, 0, -(lead_len + anode_extra)])
            cylinder(d=lead_d, h=lead_len + anode_extra);
    }
}

led();