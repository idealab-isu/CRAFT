$fn = 96;

// 10.0mm through-hole LED, 11.0mm body height (approximate standard package)
led_d = 10.0;
body_h = 11.0;

flange_d = 11.2;
flange_h = 1.0;

dome_h = 3.0;                 // rounded top portion
cyl_h = body_h - dome_h;      // straight body portion

lead_d = 0.6;
lead_pitch = 2.54;
lead_len = 25.0;
lead_exposed_below = 18.0;    // portion below flange
lead_embed = lead_len - lead_exposed_below;

flat_depth = 0.8;             // cathode flat depth
flat_width = 4.0;             // chord width control

module led_body() {
    // Body with cathode flat
    difference() {
        union() {
            // flange
            translate([0,0,0])
                cylinder(d=flange_d, h=flange_h);

            // cylindrical body
            translate([0,0,flange_h])
                cylinder(d=led_d, h=cyl_h);

            // dome (spherical cap)
            translate([0,0,flange_h + cyl_h])
                intersection() {
                    sphere(d=led_d);
                    translate([0,0,0])
                        cylinder(d=led_d, h=dome_h);
                }
        }

        // cathode flat: subtract a box to create a flat on one side
        // Place flat on +X side
        translate([led_d/2 - flat_depth, -led_d, -1])
            cube([led_d, 2*led_d, body_h + flange_h + 2], center=false);

        // small notch at rim (optional subtle)
        translate([led_d/2 - 0.4, -1.2, flange_h + 0.2])
            cube([1.2, 2.4, 1.2], center=false);
    }
}

module led_leads() {
    // Leads extend below flange; embed slightly into body
    // Anode (longer) at -X, Cathode (shorter) at +X (near flat)
    anode_x = -lead_pitch/2;
    cathode_x =  lead_pitch/2;

    // anode
    translate([anode_x, 0, flange_h - lead_embed])
        cylinder(d=lead_d, h=lead_len);

    // cathode (slightly shorter)
    translate([cathode_x, 0, flange_h - lead_embed])
        cylinder(d=lead_d, h=lead_len - 2.0);
}

module led() {
    color([0.85, 0.1, 0.1, 0.35]) led_body();
    color([0.75, 0.75, 0.78]) led_leads();
}

led();