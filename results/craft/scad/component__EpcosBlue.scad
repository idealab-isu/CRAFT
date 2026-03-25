// Thermistor: EPCOS B57861S104F40 (100k, 1%) - simplified 3D package
// Small epoxy bead/disc with TWO radial leads (single connected solid)

// ---------- Quality ----------
$fn = 64;

// ---------- Parameters (mm) ----------
bead_d = 2.2;                 // bead/disc diameter
bead_t = 1.6;                 // bead thickness (along lead pitch axis)
bead_round = 0.35;            // edge rounding amount (visual)

lead_pitch = 2.5;             // lead spacing at bead exit (center-to-center)
lead_d = 0.5;
lead_len = 25.0;              // lead length below bead

exit_boss_d = 0.95;           // small boss around each lead exit
exit_boss_l = 0.9;            // boss length along pitch axis

tinning_len = 3.0;
tinning_d_factor = 1.10;

overlap = 0.25;               // overlap to guarantee manifold union

// ---------- Helpers ----------
module cyl_x(r, h) { rotate([0,90,0]) cylinder(r=r, h=h, center=true); }
module cyl_z(r, h) { cylinder(r=r, h=h, center=true); }

// ---------- Geometry ----------
module bead_disc() {
    // Disc-like bead with slightly rounded edges (hull of two discs)
    // Oriented so lead pitch is along X, leads go along -Z.
    hull() {
        translate([0, 0, -bead_round/2])
            cyl_x(bead_d/2, bead_t - bead_round);
        translate([0, 0,  bead_round/2])
            cyl_x(bead_d/2, bead_t - bead_round);
    }
}

module exit_bosses() {
    // Bosses centered at lead exit points; overlap into bead
    for (s = [-1, 1]) {
        translate([s*lead_pitch/2, 0, 0])
            cyl_x(exit_boss_d/2, exit_boss_l + 2*overlap);
    }
}

module leads() {
    // Leads start at bead center plane (z=0) and extend downward.
    // Center each lead so its top slightly overlaps into bead/boss.
    z_center = -(lead_len/2) + overlap;

    for (s = [-1, 1]) {
        translate([s*lead_pitch/2, 0, z_center])
            cyl_z(lead_d/2, lead_len + 2*overlap);
    }
}

module lead_tinning() {
    // Slightly thicker tinning at the bottom end of each lead
    // Bottom of lead is at z = -lead_len + 2*overlap (given z_center above)
    z_bottom = -lead_len + 2*overlap;
    z_tin_center = z_bottom + tinning_len/2;

    for (s = [-1, 1]) {
        translate([s*lead_pitch/2, 0, z_tin_center])
            cyl_z((lead_d*tinning_d_factor)/2, tinning_len);
    }
}

module thermistor_epcos_b57861() {
    union() {
        bead_disc();
        exit_bosses();
        leads();
        lead_tinning();
    }
}

// ---------- Final ----------
thermistor_epcos_b57861();