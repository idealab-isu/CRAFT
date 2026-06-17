module chamfered_bar() {
    difference() {
        cube([85.1, 22.5, 10.4], center = true);
        translate([-42.55, -11.25, 0])
            rotate([0, 0, 45])
            cube([15, 15, 10.4], center = true);
        translate([42.55, -11.25, 0])
            rotate([0, 0, 45])
            cube([15, 15, 10.4], center = true);
    }
}

module prong() {
    difference() {
        cube([10, 5, 20], center = true);
        translate([-5, -2.5, 5])
            cube([10, 5, 5], center = true);
    }
}

module bracket() {
    chamfered_bar();
    translate([-20, 0, 5.2])
        prong();
    translate([20, 0, 5.2])
        prong();
}

bracket();