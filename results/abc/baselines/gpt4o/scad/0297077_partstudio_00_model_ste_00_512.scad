module flanged_hub() {
    difference() {
        union() {
            // Main cylinder
            cylinder(h=0.08, d=0.06, $fn=64);
            
            // Flange
            translate([0, 0, 0.08])
                cylinder(h=0.01, d=0.1, $fn=64);
            
            // Collar
            translate([0, 0, 0.02])
                cylinder(h=0.01, d=0.07, $fn=64);
        }
        
        // Hexagonal through-bore
        translate([0, 0, -0.01])
            rotate([0, 0, 30])
                linear_extrude(height=0.1)
                    polygon(points=[[0.015, 0], [0.0075, 0.013], [-0.0075, 0.013], [-0.015, 0], [-0.0075, -0.013], [0.0075, -0.013]]);
        
        // Diamond-shaped recesses
        for (i = [0, 90, 180, 270]) {
            rotate([0, 0, i])
                translate([0.04, 0, 0.09])
                    rotate([0, 0, 45])
                        linear_extrude(height=0.005)
                            square([0.01, 0.01], center=true);
        }
    }
}

flanged_hub();