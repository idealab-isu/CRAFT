module handwheel() {
    difference() {
        union() {
            // Outer disk with thick rim
            cylinder(h=10, r=50, $fn=64);
            // Central hub
            translate([0, 0, 10])
                cylinder(h=10, r=20, $fn=64);
            // Cylindrical post/shaft
            translate([0, 0, 20])
                cylinder(h=10, r=10, $fn=64);
        }
        // Hexagonal bore
        translate([0, 0, 10])
            rotate([0, 0, 90])
                linear_extrude(height=30)
                    polygon(points=[[5, 0], [2.5, 4.33], [-2.5, 4.33], [-5, 0], [-2.5, -4.33], [2.5, -4.33]]);
        // Curved rectangular cutouts
        for (i = [0:3]) {
            rotate([0, 0, i * 90])
                translate([35, 0, 5])
                    rotate([0, 90, 0])
                        cylinder(h=10, r=5, $fn=64);
        }
    }
}

handwheel();