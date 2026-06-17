$fn = 128;

module tubing(OD, ID, length, centered=false) {
    eps = 0.05;

    // Robust, non-empty geometry
    OD2 = max(OD, eps);
    ID2 = min(max(ID, 0), OD2 - 2*eps);
    L   = max(length, eps);

    // Place tube either centered at origin or sitting on Z=0
    zc = centered ? 0 : L/2;

    translate([0, 0, zc])
    difference() {
        cylinder(d=OD2, h=L, center=true);
        // Slightly longer inner cut ensures a clean through-bore
        cylinder(d=ID2, h=L + 2*eps, center=true);
    }
}

// Example: neoprene tubing
tubing(20, 15, 100, centered=true);