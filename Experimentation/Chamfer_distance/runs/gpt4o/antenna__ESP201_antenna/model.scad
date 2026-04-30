$fn = 64;

module antenna() {
    // Base cylinder
    cylinder(h = 20.6, d1 = 9.5, d2 = 9.5, center = true);

    // Pivot cylinder
    translate([0, 0, 20.6 / 2])
        cylinder(h = 6.45, d1 = 9.5, d2 = 9.5, center = true);

    // Folding whip section
    translate([0, 0, 20.6 / 2 + 6.45])
        cylinder(h = 108.5 - 20.6 - 6.45, d1 = 9.5, d2 = 7.9, center = true);
}

// Center the model near the origin
translate([0, 0, -108.5 / 2])
    antenna();