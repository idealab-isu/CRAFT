$fn = 96;

module led_3mm_through_hole(body_d=3.0, body_h=3.15, flange_d=3.4, flange_h=0.35,
                           dome_h=1.2, lead_d=0.5, lead_len=25, lead_pitch=2.54,
                           lead_exposed_below=18, lead_standoff=0.2) {

    // Body: cylindrical base + rounded dome
    color([0.85,0.1,0.1,0.85])
    union() {
        // Flange at bottom
        translate([0,0,0])
            cylinder(d=flange_d, h=flange_h);

        // Main cylindrical body
        translate([0,0,flange_h])
            cylinder(d=body_d, h=max(0, body_h - flange_h));

        // Dome (spherical cap approximation)
        translate([0,0,body_h])
            intersection() {
                sphere(d=body_d);
                translate([-body_d, -body_d, 0])
                    cube([2*body_d, 2*body_d, dome_h], center=false);
            }
    }

    // Leads
    color([0.75,0.75,0.75])
    union() {
        // Lead positions (centered about origin)
        x1 = -lead_pitch/2;
        x2 =  lead_pitch/2;

        // Leads extend below body; slight standoff from flange
        translate([x1,0,-lead_exposed_below])
            cylinder(d=lead_d, h=lead_exposed_below + lead_standoff);

        translate([x2,0,-lead_exposed_below])
            cylinder(d=lead_d, h=lead_exposed_below + lead_standoff);

        // Optional extra length above flange (inside body) for visual continuity
        translate([x1,0,0])
            cylinder(d=lead_d, h=flange_h + 0.6);

        translate([x2,0,0])
            cylinder(d=lead_d, h=flange_h + 0.6);
    }
}

led_3mm_through_hole(body_d=3.0, body_h=3.15);