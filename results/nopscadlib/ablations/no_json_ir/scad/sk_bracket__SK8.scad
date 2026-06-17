module shaft_support_bracket() {
    base_block();
    rod_seat_bore();
    mounting_holes();
    clamp_split();
    clamp_bolt_holes();
}

module base_block() {
    difference() {
        cube([20, 20, 10]);
        translate([5, 5, 0])
            cylinder(h = 10, d = 8.5, center = true);
    }
}

module rod_seat_bore() {
    translate([10, 10, 10])
        cylinder(h = 10, d = 8.5, center = true);
}

module mounting_holes() {
    translate([5, 5, 0])
        cylinder(h = 10, d = 3, center = true);
    translate([15, 5, 0])
        cylinder(h = 10, d = 3, center = true);
}

module clamp_split() {
    translate([10, 10, 10])
        rotate([90, 0, 0])
        cube([20, 0.5, 10], center = true);
}

module clamp_bolt_holes() {
    translate([5, 10, 15])
        rotate([90, 0, 0])
        cylinder(h = 20, d = 3, center = true);
    translate([15, 10, 15])
        rotate([90, 0, 0])
        cylinder(h = 20, d = 3, center = true);
}

shaft_support_bracket();