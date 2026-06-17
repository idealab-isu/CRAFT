// Honeywell 135-104LAC-J01 style radial leaded NTC thermistor (approximate geometry)
// One connected solid; all placements derived from dimensions (no arbitrary offsets).

$fn = 64;

// ---- Parameters (mm) ----
disc_d        = 5.0;   // ceramic disc diameter (approx)
disc_t        = 2.2;   // disc thickness (approx)
edge_round_r  = 0.35;  // edge rounding radius

epoxy_d       = 3.2;   // epoxy bead at lead exit (approx)
epoxy_h       = 1.6;   // epoxy height (approx)

lead_d        = 0.45;  // lead wire diameter (approx)
lead_len      = 25.0;  // straight lead length below body
lead_spacing  = 2.5;   // lead center-to-center spacing

// Small overlap to guarantee manifold union
ov = 0.25;

// ---- Helpers ----
module rounded_disc(d, t, r) {
    // Rounded cylinder via hull of two thin cylinders
    // Ensures a recognizable disc thermistor body rather than a long cylinder.
    hull() {
        translate([0,0, r]) cylinder(d=d, h=max(0.01, t-2*r));
        translate([0,0, t-r]) cylinder(d=d, h=max(0.01, t-2*r));
    }
    // Add edge fillets with spheres (subtle)
    // Keep it a single solid by unioning.
    for (z = [r, t-r])
        translate([0,0,z]) sphere(r=r);
}

module lead_wire(h) {
    cylinder(d=lead_d, h=h);
}

module lead_exit_bead() {
    // Small epoxy bead around each lead where it meets the disc
    // Centered on lead axis, sitting just below the disc.
    cylinder(d=epoxy_d, h=epoxy_h);
}

module thermistor_135_104LAC_J01() {
    // Coordinate system:
    // z=0 at bottom of leads; leads go up to the disc.
    // Disc sits above the lead exit beads.

    // Derived Z positions
    disc_z0   = lead_len + epoxy_h - ov;          // disc bottom slightly overlaps beads
    disc_zc   = disc_z0 + disc_t/2;
    bead_z0   = lead_len - ov;                    // bead starts at top of lead with overlap

    union() {
        // Disc body
        translate([0,0,disc_z0])
            rounded_disc(disc_d, disc_t, edge_round_r);

        // Leads + exit beads (connected to disc via overlap)
        for (sx = [-1, 1]) {
            x = sx * lead_spacing/2;

            // Lead wire
            translate([x,0,0])
                lead_wire(lead_len + ov);

            // Epoxy bead at exit
            translate([x,0,bead_z0])
                lead_exit_bead();

            // Small tapered transition into disc (ensures visible connection and avoids "floating")
            // Starts at top of bead and slightly penetrates disc.
            translate([x,0,bead_z0 + epoxy_h - ov])
                cylinder(h=ov + 0.6, d1=epoxy_d, d2=lead_d);
        }

        // Small central underside meniscus (typical molded/epoxy underside look)
        // Connects to disc underside and overlaps into it.
        translate([0,0,disc_z0 - 0.6])
            cylinder(h=0.6 + ov, d1=disc_d*0.55, d2=disc_d*0.75);
    }
}

thermistor_135_104LAC_J01();