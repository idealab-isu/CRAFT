// Aluminium rectangular box section: 50.8mm x 38.1mm x 3.0mm wall
// Length is along Z. Model is one connected solid (hollow tube via difference).

module rectangular_tube(length=100, outer_w=50.8, outer_h=38.1, t=3.0) {
    eps = 0.05; // small overlap to ensure clean boolean cut-through

    inner_w = outer_w - 2*t;
    inner_h = outer_h - 2*t;

    assert(length > 0, "Length must be > 0.");
    assert(inner_w > 0 && inner_h > 0, "Wall thickness too large for given outer dimensions.");

    difference() {
        cube([outer_w, outer_h, length], center=true);

        // Inner void: slightly longer so it fully cuts through both ends
        cube([inner_w, inner_h, length + 2*eps], center=true);
    }
}

// Example usage
rectangular_tube(length=100, outer_w=50.8, outer_h=38.1, t=3.0);