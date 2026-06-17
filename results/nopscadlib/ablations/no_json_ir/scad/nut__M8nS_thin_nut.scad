$fn = 96;

module hex_prism_af(af=13.0, h=4.0, center=true) {
    // Regular hex: across-flats (AF) = 2 * apothem
    // For a hex made as a 6-sided cylinder, apothem = R * cos(30)
    // => R = AF / (2*cos(30))
    R = af / (2 * cos(30));
    cylinder(h=h, r=R, $fn=6, center=center);
}

module hex_nut(af=13.0, thickness=4.0, screw_d=8.0, clearance=0.5) {
    hole_d = screw_d + clearance;
    eps = 0.02;

    difference() {
        hex_prism_af(af=af, h=thickness, center=true);
        cylinder(d=hole_d, h=thickness + 2*eps, center=true);
    }
}

hex_nut(af=13.0, thickness=4.0, screw_d=8.0, clearance=0.5);