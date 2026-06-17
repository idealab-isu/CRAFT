// Thermistor: EPCOS/TDK B57861S104F40 (100k, 1%) - simplified 3D envelope
// One connected solid, disc-like epoxy body with visible lead exit points and straight radial leads

$fn = 96;

// -------- Parameters (mm) --------
body_d            = 4.2;   // epoxy disc diameter
body_t            = 2.3;   // epoxy thickness
body_edge_round   = 0.55;  // edge rounding radius

lead_d            = 0.50;  // lead wire diameter
lead_spacing      = 2.5;   // lead pitch (center-to-center)
lead_len_below    = 20;    // lead length below body

embed_into_body   = 1.0;   // lead embed depth into body (for connectivity)
exit_boss_d       = 1.15;  // small boss around lead exit to make leads visible in side/front views
exit_boss_h       = 0.55;  // boss height (protrudes from body face)

overlap           = 0.20;  // overlap to guarantee manifold union

// -------- Helpers --------
module rounded_disc(d, t, r) {
    inner_d = max(0.01, d - 2*r);
    inner_t = max(0.01, t - 2*r);
    minkowski() {
        cylinder(d=inner_d, h=inner_t, center=true);
        sphere(r=r);
    }
}

module lead_wire(z0, z1, d) {
    h = z1 - z0;
    translate([0,0,(z0+z1)/2])
        cylinder(d=d, h=h, center=true);
}

// -------- Assembly --------
module thermistor_B57861S104F40() {

    // Body centered at Z=0. Leads exit from the bottom face and extend downward (negative Z).
    z_body_top    =  body_t/2;
    z_body_bottom = -body_t/2;

    // Lead starts embedded inside body and ends below
    z_lead_top = z_body_bottom + embed_into_body;                 // inside body (near bottom face)
    z_lead_bot = z_body_bottom - lead_len_below;                  // below body

    // Exit boss protrudes slightly below the body to be visible in orthographic side/front views
    z_boss_center = z_body_bottom - exit_boss_h/2 + overlap;       // overlaps into body

    union() {
        // Epoxy body
        rounded_disc(body_d, body_t, body_edge_round);

        // Leads + exit features
        for (sx = [-1, 1]) {
            x = sx * lead_spacing/2;

            // Lead wire (connected: overlaps into body)
            translate([x, 0, 0])
                lead_wire(z_lead_bot, z_lead_top + overlap, lead_d);

            // Exit boss (connected: overlaps body and lead)
            translate([x, 0, z_boss_center])
                cylinder(d=exit_boss_d, h=exit_boss_h + overlap, center=true);

            // Small meniscus at exit (connected)
            translate([x, 0, z_body_bottom + embed_into_body/2])
                sphere(d = lead_d * 1.35);
        }
    }
}

thermistor_B57861S104F40();