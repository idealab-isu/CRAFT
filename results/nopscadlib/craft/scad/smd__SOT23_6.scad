$fn = 48;

// Target overall size (mm)
body_L = 3.0;
body_W = 1.6;
body_H = 1.05;

// Terminations (metal ends) - kept flush with body envelope
term_L = 0.35;
term_thk = 0.05;
term_W_margin = 0.10;

// Top marking (slightly recessed)
mark_L = 1.0;
mark_W = 0.5;
mark_thk = 0.02;

// Body edge shaping (top chamfer only)
edge_chamfer = 0.12;

// Small overlap to guarantee watertight unions/differences
eps = 0.02;

// --- Helpers ---
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);
ch = clamp(edge_chamfer, 0, min(body_L, body_W, body_H)/3);

// --- Geometry ---
module body_with_top_chamfer() {
    difference() {
        cube([body_L, body_W, body_H], center=true);

        // Remove material at the top edges to create a simple chamfer band
        // Long edges (along X) at +Z, +/-Y
        for (sy = [-1, 1])
            translate([0,
                       sy*(body_W/2 - ch/2 + eps/2),
                       body_H/2 - ch/2 + eps/2])
                cube([body_L + 2*eps, ch + eps, ch + eps], center=true);

        // Short edges (along Y) at +Z, +/-X
        for (sx = [-1, 1])
            translate([sx*(body_L/2 - ch/2 + eps/2),
                       0,
                       body_H/2 - ch/2 + eps/2])
                cube([ch + eps, body_W + 2*eps, ch + eps], center=true);
    }
}

module termination(sx=1) {
    // Termination sits on the bottom face and overlaps into the body by eps.
    // It does NOT extend beyond the overall [body_L, body_W, body_H] envelope.
    translate([sx*(body_L/2 - term_L/2 - eps),
               0,
               -body_H/2 + term_thk/2 + eps])
        cube([term_L, body_W - 2*term_W_margin, term_thk], center=true);
}

module recessed_mark() {
    // Recess into the top surface
    translate([0, 0, body_H/2 - mark_thk/2 + eps])
        cube([mark_L, mark_W, mark_thk + 2*eps], center=true);
}

// --- Final model: one connected solid, overall size matches body_* ---
difference() {
    union() {
        body_with_top_chamfer();
        termination(1);
        termination(-1);
    }
    recessed_mark();
}