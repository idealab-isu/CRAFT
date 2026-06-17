module mounting_bracket() {
    difference() {
        // Base plate with rounded corners
        union() {
            // Main rectangular base
            cube([22, 15, 2], center = true);
            // Rounded corners
            translate([-11, -7.5, 0])
                cylinder(h = 2, r = 2, $fn = 64);
            translate([11, -7.5, 0])
                cylinder(h = 2, r = 2, $fn = 64);
            translate([-11, 7.5, 0])
                cylinder(h = 2, r = 2, $fn = 64);
            translate([11, 7.5, 0])
                cylinder(h = 2, r = 2, $fn = 64);
        }
        
        // Through-holes
        translate([-7, 0, 0])
            cylinder(h = 10, r = 1.5, $fn = 64);
        translate([7, 0, 0])
            cylinder(h = 10, r = 1.5, $fn = 64);
        
        // Semicylindrical cutout
        translate([0, 0, -1])
            rotate([90, 0, 0])
            cylinder(h = 15, r = 3, $fn = 64);
    }
    
    // Rectangular boss
    translate([0, 0, 2])
        cube([10, 5, 4], center = true);
}

mounting_bracket();