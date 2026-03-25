module bracket() {
    difference() {
        union() {
            // Main body
            translate([-50, -10, 0])
            cube([100, 20, 5]);

            // Flanged end
            translate([-60, -20, 0])
            cube([20, 40, 5]);

            // Chamfered corners
            translate([50, -10, 0])
            rotate([0, 0, 45])
            cube([10, 10, 5]);

            translate([50, 10, 0])
            rotate([0, 0, -45])
            cube([10, 10, 5]);

            // Embossed V-shape
            translate([-30, -5, 5])
            linear_extrude(height=1)
            polygon(points=[[0, 0], [10, 5], [0, 10], [-10, 5]]);
        }

        // Through-holes on flanged end
        translate([-55, -15, -1])
        cylinder(h=7, r=2, $fn=64);

        translate([-55, 15, -1])
        cylinder(h=7, r=2, $fn=64);
    }
}

bracket();