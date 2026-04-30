$fn = 64;

module led() {
    // Lens
    translate([0, 0, 5])
        cylinder(h = 10, d = 10, center = true);

    // Body
    translate([0, 0, -10])
        cylinder(h = 10, d = 5, center = true);

    // Leads
    translate([-1.5, 0, -20])
        cylinder(h = 10, d = 1, center = true);
    translate([1.5, 0, -20])
        cylinder(h = 10, d = 1, center = true);
}

led();