// Honeywell 135-104LAC-J01 (100K NTC) – radial epoxy bead with two leads
// Corrected: single connected solid, no floating caps/discs, all placements derived from dimensions.

$fn = 96;

// ---- Parameters (mm) ----
bead_d      = 2.5;     // epoxy bead diameter
bead_len    = 6.0;     // epoxy bead length (along X)

lead_d      = 0.5;     // lead wire diameter
lead_pitch  = 2.54;    // lead spacing (Y)
lead_len    = 25.0;    // straight lead length from bead exit

neck_len    = 1.2;     // transition from bead to lead
meniscus_len= 0.7;     // epoxy meniscus length at each end
flat_depth  = 0.35;    // small flat on bead (+Z)

overlap     = 0.35;    // guaranteed overlap for manifold union

// ---- Derived ----
bead_r = bead_d/2;
lead_r = lead_d/2;

x_bead_min = -bead_len/2;
x_bead_max =  bead_len/2;

// Lead/neck centers (all computed)
x_neck_c = x_bead_max + neck_len/2 - overlap/2;
x_lead_c = x_bead_max + neck_len + lead_len/2 - overlap/2;

// Meniscus centers (kept inside bead so they cannot float)
x_men_pos = x_bead_max - meniscus_len/2;
x_men_neg = x_bead_min + meniscus_len/2;

// Small exit boss to resemble molded epoxy head around lead exits
boss_len = max(1.2, neck_len + 0.6);
boss_r   = bead_r * 1.05;
x_boss_c = x_bead_max - boss_len/2 + overlap; // overlaps into bead

// ---- Modules ----
module bead_body() {
    // Main epoxy bead with a subtle flat on +Z
    difference() {
        rotate([0,90,0])
            cylinder(r=bead_r, h=bead_len, center=true);

        // Flat cut: cube intersects bead; never creates separate parts
        translate([0, 0, bead_r - flat_depth])
            cube([bead_len + 2*overlap + 2, bead_d*3, bead_d*3], center=true);
    }
}

module meniscus(xc, dir=1) {
    // Slight taper near each end, fully inside bead envelope (cannot detach)
    // dir=+1 for +X end, dir=-1 for -X end
    translate([xc, 0, 0])
        rotate([0,90,0])
            cylinder(
                h = meniscus_len + overlap,
                r1 = (dir>0) ? bead_r*0.98 : bead_r*0.85,
                r2 = (dir>0) ? bead_r*0.85 : bead_r*0.98,
                center=true
            );
}

module exit_boss() {
    // Molded epoxy head around lead exits (connected to bead by overlap)
    translate([x_boss_c, 0, 0])
        rotate([0,90,0])
            cylinder(h=boss_len + overlap, r=boss_r, center=true);
}

module neck_to_lead(yoff) {
    // Neck from bead/boss to lead, with overlap into boss
    translate([x_neck_c, yoff, 0])
        rotate([0,90,0])
            cylinder(
                h = neck_len + overlap,
                r1 = max(lead_r*1.15, bead_r*0.40),
                r2 = lead_r*1.05,
                center=true
            );
}

module lead_wire(yoff) {
    translate([x_lead_c, yoff, 0])
        rotate([0,90,0])
            cylinder(h=lead_len + overlap, r=lead_r, center=true);
}

module lead_tip(yoff) {
    tip_len = max(0.9, lead_d*2.2);
    x_tip_c = x_bead_max + neck_len + lead_len - tip_len/2 + overlap/2;
    translate([x_tip_c, yoff, 0])
        rotate([0,90,0])
            cylinder(h=tip_len + overlap, r1=lead_r, r2=0.02, center=true);
}

module lead_web() {
    // Robust bridge at the exit plane to guarantee connectivity between both leads and boss
    // Positioned at bead end; overlaps into boss and necks.
    web_x = x_bead_max + overlap/2;
    web_w = max(0.8, overlap + 0.7);
    web_y = lead_pitch + lead_d*2.6;
    web_z = lead_d*2.0;

    translate([web_x, 0, 0])
        cube([web_w, web_y, web_z], center=true);
}

module thermistor_135_104LAC_J01() {
    union() {
        bead_body();

        // End meniscus details (embedded/overlapped)
        meniscus(x_men_pos, +1);
        meniscus(x_men_neg, -1);

        // Exit boss (molded head)
        exit_boss();

        // Leads
        for (yoff = [ lead_pitch/2, -lead_pitch/2 ]) {
            neck_to_lead(yoff);
            lead_wire(yoff);
            lead_tip(yoff);
        }

        // Connectivity reinforcement at exit
        lead_web();
    }
}

// ---- Final output ----
thermistor_135_104LAC_J01();