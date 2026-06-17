module linear_bearing_body() {
    difference() {
        cylinder(h = 24.0, d = 15.0, $fn = 100); // Outer casing
        translate([0, 0, -1]) // Extend inner bore slightly for clearance
            cylinder(h = 26.0, d = 8.0, $fn = 100); // Inner bore
    }
}

module inner_bore() {
    translate([0, 0, -1]) // Extend inner bore slightly for clearance
        cylinder(h = 26.0, d = 8.0, $fn = 100); // Inner bore
}

module outer_casing() {
    cylinder(h = 24.0, d = 15.0, $fn = 100); // Outer casing
}

module linear_bearing() {
    linear_bearing_body();
}

module screw_and_washer() {
    // Placeholder for screw and washer, not specified in detail
    translate([0, 0, 24])
        cylinder(h = 5, d = 4, $fn = 100); // Example screw
    translate([0, 0, 23])
        cylinder(h = 1, d = 8, $fn = 100); // Example washer
}

linear_bearing();