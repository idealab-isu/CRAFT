// SMD package with terminations
// Overall target dimensions: [3.0, 1.8, 0.9] (L, W, H)

$fn = 48;

// Target dimensions
body_length = 3.0;
body_width  = 1.8;
body_height = 0.9;

// Small overlap to guarantee a single connected solid
overlap = 0.02;

module smd_pkg(L, W, H) {
    // Termination length (each end), kept reasonable
    tL = min(L*0.18, 0.55);
    tL = min(tL, L*0.30);

    // Top chamfer amount (visual only)
    ch = min(H*0.18, 0.18);
    ch = min(ch, min(W, H)*0.25);

    // Ceramic core length so that overall length remains exactly L
    coreL = max(L - 2*tL, L*0.50);

    // Ensure chamfer doesn't invert geometry
    topL = max(coreL - 2*ch, coreL*0.60);
    topW = max(W     - 2*ch, W*0.60);
    topH = max(H     - ch,   H*0.70);

    union() {
        // Ceramic body (chamfered via hull)
        hull() {
            cube([coreL, W, H], center=true);
            translate([0, 0, ch/2])
                cube([topL, topW, topH], center=true);
        }

        // Metal terminations: full-height end caps to match views and ensure connectivity
        for (sx = [-1, 1]) {
            translate([sx*(coreL/2 + tL/2 - overlap), 0, 0])
                cube([tL, W, H], center=true);
        }
    }
}

smd_pkg(body_length, body_width, body_height);