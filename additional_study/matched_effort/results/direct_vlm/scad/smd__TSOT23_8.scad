$fn = 64;

size = [3.0, 1.8, 0.9]; // [X, Y, Z] in mm

// Rounded rectangular prism (no Minkowski). Uses hull of 8 spheres.
module rounded_box(d=[3,1.8,0.9], r=0.12) {
    rr = min(r, d[0]/2 - 0.001, d[1]/2 - 0.001, d[2]/2 - 0.001);
    hull() {
        for (sx = [-1, 1], sy = [-1, 1], sz = [-1, 1])
            translate([sx*(d[0]/2 - rr), sy*(d[1]/2 - rr), sz*(d[2]/2 - rr)])
                sphere(r=rr);
    }
}

// SMD chip with end terminations. Overall envelope matches sz exactly.
module smd_chip(sz=[3.0, 1.8, 0.9]) {
    L = sz[0];
    W = sz[1];
    H = sz[2];

    term_len = min(L*0.22, L/2 - 0.05);
    body_len = L - 2*term_len;

    overlap = 0.03; // ensures one connected solid

    body_r = min(0.10, W*0.08, H*0.12);
    term_r = min(0.06, W*0.06, H*0.10);

    union() {
        // Center ceramic body
        rounded_box([body_len + 2*overlap, W, H], r=body_r);

        // Left termination (connected via overlap)
        translate([-(body_len/2 + term_len/2 - overlap), 0, 0])
            rounded_box([term_len + 2*overlap, W, H], r=term_r);

        // Right termination (connected via overlap)
        translate([ (body_len/2 + term_len/2 - overlap), 0, 0])
            rounded_box([term_len + 2*overlap, W, H], r=term_r);
    }
}

smd_chip(size);