// SMD package target overall size: [3.0, 1.8, 0.9] (L, W, H)
// One connected solid, simple rectangular SMD with subtle end terminations.

$fn = 48;

// -------- Parameters --------
L = 3.0;   // X overall
W = 1.8;   // Y overall
H = 0.9;   // Z overall

// Terminations (kept within overall envelope)
term_len   = 0.55;  // along X from each end
term_thk   = 0.08;  // metal thickness (top/bottom)
term_drop  = 0.22;  // wrap down the end face (from top)
term_inset = 0.06;  // inset from Y edges

// Small top mark (subtle)
mark_d = 0.35;
mark_h = 0.03;

overlap = 0.02;     // ensures connectivity / avoids coplanar issues

// -------- Helpers --------
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// -------- Body (simple rectangular) --------
module body_solid() {
    cube([L, W, H], center=true);
}

// -------- Termination (end cap) --------
module termination_end(signx=1) {
    x_center = signx*(L/2 - term_len/2);

    term_w = clamp(W - 2*term_inset, 0.2, W);

    union() {
        // Bottom pad (embedded slightly into body for union connectivity)
        translate([x_center, 0, -H/2 + term_thk/2 + overlap])
            cube([term_len, term_w, term_thk + 2*overlap], center=true);

        // Top pad (embedded slightly into body for union connectivity)
        translate([x_center, 0,  H/2 - term_thk/2 - overlap])
            cube([term_len, term_w, term_thk + 2*overlap], center=true);

        // End-face wrap (kept within overall length; sits at end face)
        // Centered at x = +/- (L/2 - term_thk/2) so it does not protrude beyond L.
        translate([signx*(L/2 - term_thk/2), 0, H/2 - term_drop/2])
            cube([term_thk, term_w, term_drop], center=true);
    }
}

// -------- Small top mark (connected) --------
module top_mark() {
    translate([0, 0, H/2 - mark_h/2 - overlap])
        cylinder(d=mark_d, h=mark_h + 2*overlap, center=true);
}

// -------- Complete package (ONE connected solid) --------
module smd_complete() {
    union() {
        body_solid();
        termination_end(-1);
        termination_end( 1);
        top_mark();
    }
}

smd_complete();