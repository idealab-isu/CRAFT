// SMD package: overall dimensions [3, 1.4, 1.0] (L, W, H)
// One connected solid with subtle SMD-like end terminations (still a single manifold).

$fn = 48;

L = 3.0;
W = 1.4;
H = 1.0;

// Termination geometry (kept within overall envelope)
term_len = 0.45;                 // length of each end termination
overlap  = 0.02;                 // small overlap to guarantee connectivity
edge_r   = min(0.12, W/4, H/4);   // gentle edge rounding

module rounded_block(size=[1,1,1], r=0.1) {
    // Minkowski rounding; stays within size by shrinking core first
    core = [max(size[0]-2*r, 0.001), max(size[1]-2*r, 0.001), max(size[2]-2*r, 0.001)];
    minkowski() {
        cube(core, center=true);
        sphere(r=r);
    }
}

union() {
    // Main ceramic body (between terminations)
    body_len = L - 2*term_len + 2*overlap;
    color([0.85, 0.85, 0.80])
        rounded_block([body_len, W, H], r=edge_r);

    // End terminations (connected, within overall length)
    for (sx = [-1, 1]) {
        translate([sx*(L/2 - term_len/2), 0, 0])
            color([0.70, 0.70, 0.70])
                rounded_block([term_len + overlap, W, H], r=edge_r);
    }
}