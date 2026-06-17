$fn=64;

module bracket() {
    difference() {
        union() {
            // Main body with rounded ends
            hull() {
                translate([-50, 0, 0]) cylinder(h=5, r=5);
                translate([50, 0, 0]) cylinder(h=5, r=5);
            }
            // Central thickened body
            translate([-30, -5, -2.5]) cube([60, 10, 5]);
            // Stepped, faceted surfaces
            translate([-20, -7, -3]) cube([40, 14, 6]);
            translate([-10, -9, -4]) cube([20, 18, 8]);
        }
        // Rectangular through-windows
        translate([-40, -3, -2.5]) cube([20, 6, 5]);
        translate([20, -3, -2.5]) cube([20, 6, 5]);
        // Circular through-holes at ends
        translate([-50, 0, -2.5]) cylinder(h=5, r=2);
        translate([50, 0, -2.5]) cylinder(h=5, r=2);
    }
}

translate([0, 0, 0.1])
scale([0.01, 0.01, 0.04])
bracket();