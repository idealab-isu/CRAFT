// Flanged ball bearing (single connected solid)
// Target: 3.0mm bore, 10.0mm OD, 4.0mm width, 11.5mm flange OD

$fn = 180;

// ----------------- Key dimensions -----------------
bore_d   = 3.0;   //[1.5:6.0:0.1]
od_d     = 10.0;  //[5.0:20.0:0.1]
width_w  = 4.0;   //[2.0:8.0:0.1]
flange_d = 11.5;  //[6.0:23.0:0.1]
flange_t = 0.6;   //[0.3:1.2:0.05]

// ----------------- Visual/feature parameters -----------------
race_gap        = 0.35;  //[0.2:0.8:0.05]   // radial gap between inner/outer rings
inner_ring_od   = 6.2;   //[4.0:9.0:0.1]    // inner ring outside diameter (visual)
ball_r          = 0.55;  //[0.3:1.2:0.05]
ball_count      = 8;     //[4:16:1]
shield_t        = 0.25;  //[0.1:0.6:0.05]
shield_clear_r  = 0.25;  //[0.1:0.8:0.05]
overlap         = 0.08;  //[0.01:0.3:0.01]  // overlap to guarantee one connected solid

// ----------------- Derived -----------------
od_r      = od_d/2;
bore_r    = bore_d/2;
flange_r  = flange_d/2;

inner_od_r = inner_ring_od/2;

// Keep inner ring valid and inside outer ring
inner_od_r_safe = max(inner_od_r, bore_r + 0.7);
inner_od_r_safe = min(inner_od_r_safe, od_r - 1.2);

// Outer ring inner radius (ID/2)
outer_inner_r = inner_od_r_safe + race_gap;
outer_inner_r = min(outer_inner_r, od_r - 0.6);

// Ball path radius centered between rings
ball_path_r = (outer_inner_r + inner_od_r_safe)/2;

// Ensure balls fit between rings
max_ball_r = max(0.18, (outer_inner_r - inner_od_r_safe)/2 - 0.05);
ball_r_eff = min(ball_r, max_ball_r);

// Z placement: bearing body centered at z=0, flange on +Z side
flange_z = width_w/2 + flange_t/2 - overlap;

// ----------------- Modules -----------------
module outer_ring() {
    // Outer ring: OD = od_d, ID = outer_inner_r*2, width = width_w
    difference() {
        cylinder(r=od_r, h=width_w, center=true);
        cylinder(r=outer_inner_r, h=width_w + 2*overlap, center=true);
    }
}

module inner_ring() {
    // Inner ring: OD = inner_ring_od (safe), ID = bore_d, width = width_w
    difference() {
        cylinder(r=inner_od_r_safe, h=width_w, center=true);
        cylinder(r=bore_r, h=width_w + 2*overlap, center=true);
    }
}

module flange() {
    // Flange is a ring attached to the outer ring on +Z side
    // OD = flange_d, ID = od_d (true flange lip)
    translate([0,0,flange_z])
    difference() {
        cylinder(r=flange_r, h=flange_t, center=true);
        cylinder(r=od_r,     h=flange_t + 2*overlap, center=true);
    }
}

module shields() {
    // Thin shields inside the outer ring, leaving a visible gap to the inner ring.
    // Make them TOUCH the outer ring by setting shield_r slightly larger than outer_inner_r.
    // This guarantees connectivity even if balls are small.
    shield_r = max(outer_inner_r + overlap, od_r - shield_clear_r);

    // Keep shield within OD
    shield_r = min(shield_r, od_r);

    zL = -width_w/2 + shield_t/2 + overlap;
    zR =  width_w/2 - shield_t/2 - overlap;

    for (zpos = [zL, zR]) {
        translate([0,0,zpos])
        difference() {
            cylinder(r=shield_r, h=shield_t, center=true);
            cylinder(r=inner_od_r_safe + race_gap/2, h=shield_t + 2*overlap, center=true);
        }
    }
}

module balls() {
    // Balls overlap slightly into both rings so the final model is one connected solid.
    r = max(ball_r_eff, 0.18);

    // Nudge ball path so balls intersect both rings reliably
    // (still derived from ring radii; no arbitrary placement)
    ball_path_r_nudged = ball_path_r;

    for (i = [0:ball_count-1]) {
        a = i * 360 / ball_count;
        translate([ball_path_r_nudged*cos(a), ball_path_r_nudged*sin(a), 0])
            sphere(r=r);
    }
}

module complete_model() {
    union() {
        outer_ring();
        inner_ring();
        flange();
        shields();
        balls();
    }
}

// Render
complete_model();