module wedge_bracket() {
    difference() {
        union() {
            // Main body
            translate([-50, -25, 0])
                cube([100, 50, 50]);

            // Sloped face
            translate([-50, -25, 0])
                linear_extrude(height=50)
                    polygon(points=[[0, 0], [100, 0], [100, 50], [0, 25]]);
            
            // Vertical flange
            translate([-50, -25, 50])
                cube([20, 50, 10]);

            // Lower protruding foot
            translate([-50, -25, -10])
                cube([20, 50, 10]);
        }

        // Recessed/through holes
        translate([-25, 0, 25])
            rotate([90, 0, 0])
                cylinder(h=50, r=2, $fn=64);

        translate([25, 0, 25])
            rotate([90, 0, 0])
                cylinder(h=50, r=2, $fn=64);
    }
}

wedge_bracket();