// SMD package: overall dimensions [8.70, 3.90, 1.25] (L, W, H)
// One connected solid with visible end terminations and a shallow top marking.

$fn = 64;

// Overall dimensions (mm)
L = 8.70;
W = 3.90;
H = 1.25;

// Small epsilon overlap to guarantee manifold unions/differences
eps = 0.02;

// Body edge rounding (kept modest so it still looks like a typical molded SMD)
edge_r = min(0.25, W*0.08, H*0.25);

// Termination geometry (end caps)
term_len = min(1.00, L*0.14);     // length of metal cap along L
term_inset = min(0.12, W*0.05);   // inset from side edges
term_thk = min(0.10, H*0.10);     // slight protrusion beyond body height for visibility

// Top marking (shallow recess)
mark_depth = min(0.06, H*0.06);
mark_r = min(0.55, W*0.18);
mark_x = L*0.22;                  // offset along length

// Rounded rectangular prism via hull of corner cylinders
module rounded_box(l, w, h, r) {
    r2 = min(r, l/2 - 0.001, w/2 - 0.001);
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(l/2 - r2), sy*(w/2 - r2), 0])
                cylinder(r=r2, h=h, center=true);
    }
}

// Main molded body (slightly shorter than overall length to leave room for end caps)
module body() {
    body_l = L - 2*term_len + 2*eps; // ensures caps overlap into body
    difference() {
        rounded_box(body_l, W, H, edge_r);

        // Recessed circular mark on top surface (connected; subtracts from body)
        translate([mark_x, 0, H/2 - mark_depth/2 + eps])
            cylinder(r=mark_r, h=mark_depth + 2*eps, center=true);
    }
}

// End terminations (metal caps) - connected with overlap into body
module terminations() {
    term_w = W - 2*term_inset;
    term_h = H + 2*term_thk; // protrude slightly above/below body
    cap_r = min(edge_r*0.8, term_len*0.25, term_w*0.25);

    for (sx = [-1, 1]) {
        // Place each cap so its outer face is at +/- L/2, with slight overlap into body
        translate([sx*(L/2 - term_len/2), 0, 0])
            rounded_box(term_len + 2*eps, term_w, term_h, cap_r);
    }
}

// Assemble as ONE connected solid with correct overall envelope L x W x H (caps may protrude slightly in Z only)
union() {
    body();
    terminations();
}