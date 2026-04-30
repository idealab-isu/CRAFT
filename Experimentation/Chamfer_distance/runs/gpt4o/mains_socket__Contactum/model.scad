translate([-42, -42, -5.25])
difference() {
    // Main body of the socket
    cube([84, 84, 10.5]);

    // Cutout for the inner part
    translate([3.6, 3.6, 0])
    cube([84 - 2 * 3.6, 84 - 2 * 3.6, 10.5]);

    // Screw holes
    translate([42 - 60.3 / 2, 42, -1])
    cylinder(h = 12, r = 2, $fn = 64);

    translate([42 + 60.3 / 2, 42, -1])
    cylinder(h = 12, r = 2, $fn = 64);
}