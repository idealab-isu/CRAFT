$fn = 96;

module led_10mm_through_hole(body_d=10.0, body_h=11.0, flange_d=11.2, flange_h=1.2,
                            dome_h=4.0, lead_d=0.6, lead_pitch=2.54, lead_len=25.0,
                            flat_depth=0.8) {

    // Body (cylindrical + dome), with a small flat on one side
    color([0.85, 0.1, 0.1, 0.85])
    difference() {
        union() {
            // Flange
            translate([0,0,0])
                cylinder(d=flange_d, h=flange_h);

            // Main cylindrical body
            translate([0,0,flange_h])
                cylinder(d=body_d, h=body_h - flange_h);

            // Dome (spherical cap)
            translate([0,0,body_h])
                intersection() {
                    sphere(d=body_d);
                    translate([0,0,0])
                        cylinder(d=body_d, h=dome_h);
                }
        }

        // Flat on side (approximate cathode flat)
        translate([body_d/2 - flat_depth, -body_d, -1])
            cube([body_d, 2*body_d, body_h + dome_h + 3], center=false);
    }

    // Leads
    color([0.75, 0.75, 0.78])
    union() {
        // Anode (longer)
        translate([lead_pitch/2, 0, -lead_len])
            cylinder(d=lead_d, h=lead_len + 0.5);

        // Cathode (slightly shorter)
        translate([-lead_pitch/2, 0, -lead_len + 2.0])
            cylinder(d=lead_d, h=lead_len - 2.0 + 0.5);
    }
}

led_10mm_through_hole(body_d=10.0, body_h=11.0);