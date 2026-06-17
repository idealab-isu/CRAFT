$fn = 64;

// Overall transformer envelope (must match): 120 x 88 x 120 (X x Y x Z)
W = 120;
D = 88;
H = 120;

module transformer() {
    // Slightly rounded edges to avoid degenerate/blank renders in some pipelines
    r = 3;

    // Ensure one connected solid (single body)
    minkowski() {
        cube([W - 2*r, D - 2*r, H - 2*r], center=true);
        sphere(r=r);
    }
}

transformer();