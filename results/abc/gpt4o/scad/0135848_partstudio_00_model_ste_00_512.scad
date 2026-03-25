module bracket() {
    difference() {
        union() {
            // Main body with a necked transition
            polygon(points=[
                [-50, -10], [-30, -10], [-20, -5], [20, -5], [30, -10], [50, -10],
                [50, 10], [30, 10], [20, 5], [-20, 5], [-30, 10], [-50, 10]
            ]);
            // Larger lobe
            translate([0, 10])
                circle(r=20, $fn=64);
        }
        // Hexagonal hole
        translate([0, -5])
            rotate([0, 0, 30])
                polygon(points=[
                    [-5, 0], [-2.5, 4.33], [2.5, 4.33],
                    [5, 0], [2.5, -4.33], [-2.5, -4.33]
                ]);
    }
}

scale([0.1, 0.1, 0.1])
    bracket();