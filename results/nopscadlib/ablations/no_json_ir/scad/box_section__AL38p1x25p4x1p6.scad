module rectangular_tube(length, outer_w=38.1, outer_h=25.4, wall=1.6) {
    eps = 0.05; // small overlap to ensure open ends and avoid coplanar faces

    inner_w = outer_w - 2*wall;
    inner_h = outer_h - 2*wall;

    assert(length > 0, "Length must be > 0.");
    assert(inner_w > 0 && inner_h > 0, "Wall thickness too large for given outer dimensions.");

    difference() {
        // Outer box section
        cube([outer_w, outer_h, length], center=true);

        // Inner void: extend beyond both ends so there are no end caps
        cube([inner_w, inner_h, length + 2*eps], center=true);
    }
}

// Example usage
rectangular_tube(100);