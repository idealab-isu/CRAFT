// SMD package: 3.0 x 1.8 x 0.9 mm
// One connected solid with simple metal end terminations and a small top polarity mark.

module smd_package(A=[3.0, 1.8, 0.9]) {
    L = A[0];
    W = A[1];
    H = A[2];

    // Termination geometry (kept within overall length)
    term_len = 0.35;                 // length of each metal end
    term_thk = 0.12;                 // thickness below body
    term_w   = W * 0.92;             // slightly inset from sides
    overlap  = 0.02;                 // small overlap to guarantee manifold union

    // Polarity mark (small shallow bump on top near one end)
    mark_r = 0.22;
    mark_h = 0.06;

    union() {
        // Main body centered at origin
        translate([-L/2, -W/2, 0])
            cube([L, W, H], center=false);

        // Metal terminations (wrap to bottom and slightly up the sides)
        // Left termination
        translate([-L/2 - overlap, -term_w/2, -term_thk])
            cube([term_len + overlap, term_w, H + term_thk], center=false);

        // Right termination
        translate([L/2 - term_len, -term_w/2, -term_thk])
            cube([term_len + overlap, term_w, H + term_thk], center=false);

        // Polarity mark on top near left end
        translate([-L/2 + term_len + mark_r*1.2, 0, H - overlap])
            cylinder(h=mark_h + overlap, r=mark_r, center=false, $fn=32);
    }
}

smd_package([3.0, 1.8, 0.9]);