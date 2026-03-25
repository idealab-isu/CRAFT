module fastener() {
    $fn = 64;
    
    // Flange
    cylinder(h = 2.0, d = 10.0, center = true);
    
    // Shank
    translate([0, 0, -8.0])
        cylinder(h = 12.0, d = 4.0, center = false);
    
    // Prongs
    translate([0, 0, -8.0])
    difference() {
        cylinder(h = 6.0, d = 4.0, center = false);
        translate([0, 0, -1.0])
            cylinder(h = 7.0, d = 3.0, center = false);
    }
    
    // Tapered prongs
    translate([0, 0, -14.0])
    union() {
        rotate([0, 0, 0])
            translate([-2.0, 0, 0])
                linear_extrude(height = 6.0)
                    polygon(points = [[0, 0], [4, 0], [2, 6]]);
        rotate([0, 0, 180])
            translate([-2.0, 0, 0])
                linear_extrude(height = 6.0)
                    polygon(points = [[0, 0], [4, 0], [2, 6]]);
    }
}

fastener();