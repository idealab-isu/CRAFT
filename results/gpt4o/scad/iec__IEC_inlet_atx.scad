module iec_inlet() {
    difference() {
        // Main body
        union() {
            // Main rectangular body
            translate([-20, -13.5, 0])
                cube([40, 27, 20]);
            // Top rounded corners
            translate([-20, 13.5, 0])
                cylinder(h=20, r=13.5, $fn=64);
            translate([20, 13.5, 0])
                cylinder(h=20, r=13.5, $fn=64);
        }
        // Cut out the inner part
        translate([-18, -11.5, -1])
            cube([36, 23, 22]);
    }
}

iec_inlet();