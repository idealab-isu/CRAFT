module rectangular_tube(length=100, outer_w=12, outer_h=8, wall=1) {
    eps = 0.02;

    inner_w = outer_w - 2*wall;
    inner_h = outer_h - 2*wall;

    assert(length > 0, "Length must be > 0.");
    assert(wall > 0, "Wall thickness must be > 0.");
    assert(inner_w > 0 && inner_h > 0, "Wall thickness too large for given outer dimensions.");

    difference() {
        // Outer solid
        cube([outer_w, outer_h, length], center=true);

        // Inner void: slightly longer to guarantee a clean through-cut
        cube([inner_w, inner_h, length + 2*eps], center=true);
    }
}

// 12mm x 8mm x 1mm wall, 100mm long
rectangular_tube(length=100, outer_w=12, outer_h=8, wall=1);