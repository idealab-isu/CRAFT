module flanged_bushing() {
    $fn = 64;
    // Main cylindrical body
    cylinder(h = 10, r = 5, center = true);
    
    // Hexagonal flange
    translate([0, 0, 5])
    rotate([0, 0, 30])
    scale([1, 1, 0.5])
    cylinder(h = 10, r = 8, center = true, $fn = 6);
}

flanged_bushing();