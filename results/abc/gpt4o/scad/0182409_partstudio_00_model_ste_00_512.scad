module knob() {
    difference() {
        union() {
            // Main barrel with scalloped edge
            rotate_extrude($fn=64)
            translate([10, 0, 0])
            circle(10, $fn=8);

            // Rounded shoulder transition
            translate([0, 0, 10])
            rotate_extrude($fn=64)
            translate([8, 0, 0])
            circle(2, $fn=64);

            // Smaller coaxial cylindrical boss
            translate([0, 0, 12])
            cylinder(h=8, r=5, $fn=64);
        }
        // Central square through-hole
        translate([-2.5, -2.5, 0])
        cube([5, 5, 20]);
    }
}

translate([0, 0, -10])
knob();