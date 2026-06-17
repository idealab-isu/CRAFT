module t_shaped_bracket() {
    difference() {
        union() {
            // Main body
            translate([-30, -10, -5])
                cube([60, 20, 10]);
            // Stem
            translate([-10, -5, -15])
                cube([20, 10, 10]);
        }
        // Circular through-hole
        translate([0, 0, -5])
            cylinder(h=10, r=5, $fn=64);
    }
}

t_shaped_bracket();