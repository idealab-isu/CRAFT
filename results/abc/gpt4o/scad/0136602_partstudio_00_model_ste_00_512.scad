module bracket() {
    difference() {
        union() {
            // Central rectangular body
            translate([-25, -10, -5])
                cube([50, 20, 10]);

            // Left wedge-shaped wing
            translate([-50, -10, -5])
                linear_extrude(height=10)
                    polygon(points=[[0, 0], [25, 0], [25, 10], [0, 5]]);

            // Right wedge-shaped wing
            translate([25, -10, -5])
                linear_extrude(height=10)
                    polygon(points=[[0, 0], [-25, 0], [-25, 10], [0, 5]]);
        }

        // Rectangular slots/pockets
        translate([-20, -5, -5.1])
            cube([10, 10, 10.2]);
        translate([10, -5, -5.1])
            cube([10, 10, 10.2]);

        // Diamond/square through-holes
        translate([-37.5, 0, -5.1])
            rotate([0, 0, 45])
                square([5, 5], center=true);
        translate([37.5, 0, -5.1])
            rotate([0, 0, 45])
                square([5, 5], center=true);

        // V-shaped notch/opening
        translate([-5, 10, -5.1])
            linear_extrude(height=10.2)
                polygon(points=[[0, 0], [5, 0], [2.5, -5]]);
    }
}

bracket();