$fn = 128;

radii = [20.4, 10.8, 5.3, 1];

module radial(rs, h=1) {
    rs_sorted = sort(rs, descending=true);

    // Build as stacked solid disks (not ring differences) so the result is
    // one connected stepped solid with visible tiers.
    step_h = h / len(rs_sorted);
    eps = 0.02; // small overlap to guarantee manifold connectivity

    union() {
        for (i = [0 : len(rs_sorted)-1]) {
            r = rs_sorted[i];
            z = i * step_h - i * eps; // overlap each tier slightly into the one below
            translate([0, 0, z])
                cylinder(r=r, h=step_h + eps, center=false);
        }
    }
}

radial(radii, h=1);