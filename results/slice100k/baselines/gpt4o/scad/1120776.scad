module teardrop_bracket() {
    difference() {
        // Main teardrop shape
        union() {
            // Main triangle
            polygon(points=[[0, 0], [18.3, 0], [9.15, 21.6]]);
            // Rounded lobes
            translate([0, 0]) circle(d=6, $fn=64);
            translate([18.3, 0]) circle(d=6, $fn=64);
        }
        // Large through-holes
        translate([0, 0]) cylinder(h=2.5, d=4, $fn=64);
        translate([18.3, 0]) cylinder(h=2.5, d=4, $fn=64);
        // Smaller through-holes
        translate([6, 10]) cylinder(h=2.5, d=2, $fn=64);
        translate([12.3, 10]) cylinder(h=2.5, d=2, $fn=64);
    }
}

translate([-9.15, -10.8, -1.25])
    teardrop_bracket();