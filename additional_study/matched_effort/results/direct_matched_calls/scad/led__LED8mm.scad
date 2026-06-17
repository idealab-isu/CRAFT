$fn = 96;

// 8.0mm through-hole LED (T-1 3/4 style), body height 9.2mm
// Dimensions are typical/approximate for visualization.

d_body = 8.0;
h_body = 9.2;

d_flange = 9.0;
h_flange = 1.2;

d_lead = 0.6;
lead_pitch = 2.54;
lead_len = 25.0;

dome_h = d_body/2;          // hemispherical-ish dome height
cyl_h = h_body - dome_h;    // cylindrical portion height

module led_body() {
    union() {
        // Flange at base
        translate([0,0,0])
            cylinder(d=d_flange, h=h_flange);

        // Cylindrical body above flange
        translate([0,0,h_flange])
            cylinder(d=d_body, h=max(0, cyl_h - h_flange));

        // Dome top
        translate([0,0,h_flange + max(0, cyl_h - h_flange)])
            intersection() {
                sphere(d=d_body);
                translate([0,0,0])
                    cylinder(d=d_body, h=dome_h);
            }

        // Flat on one side (cathode flat), subtle
        difference() {
            // no-op container to apply cut to entire body
            children();
        }
    }
}

module led_with_flat() {
    difference() {
        // Full body (flange + cylinder + dome)
        union() {
            // Flange
            cylinder(d=d_flange, h=h_flange);

            // Cylinder
            translate([0,0,h_flange])
                cylinder(d=d_body, h=max(0, cyl_h - h_flange));

            // Dome
            translate([0,0,h_flange + max(0, cyl_h - h_flange)])
                intersection() {
                    sphere(d=d_body);
                    cylinder(d=d_body, h=dome_h);
                }
        }

        // Flat cut (small chord cut)
        flat_depth = 0.8;
        translate([d_body/2 - flat_depth, -d_body, -1])
            cube([d_body, 2*d_body, h_body + 3], center=false);
    }
}

module leads() {
    // Two leads extending downward from base plane z=0
    for (sx = [-1, 1]) {
        translate([sx*lead_pitch/2, 0, -lead_len])
            cylinder(d=d_lead, h=lead_len);
    }
}

union() {
    // Body sits on z=0 at flange bottom
    color([0.85, 0.1, 0.1, 0.35]) led_with_flat();

    // Leads
    color([0.75, 0.75, 0.75]) leads();
}