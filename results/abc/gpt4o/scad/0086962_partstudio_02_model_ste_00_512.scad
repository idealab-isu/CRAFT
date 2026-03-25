module boss() {
    cube([0.01, 0.01, 0.01], center=true);
}

module panel_with_bosses() {
    difference() {
        cube([0.1, 0.001, 0.1], center=true);
        translate([-0.04, 0.0005, -0.03]) boss();
        translate([0.03, 0.0005, -0.02]) boss();
        translate([-0.02, 0.0005, 0.02]) boss();
        translate([0.04, 0.0005, 0.03]) boss();
    }
}

panel_with_bosses();