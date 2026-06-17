module hex_plate_with_dome() {
    // Hexagonal plate dimensions
    hex_radius = 23.1; // Half of 46.2 mm
    plate_thickness = 5.0;
    
    // Dome dimensions
    dome_radius = 20.0;
    dome_height = 20.0; // Hemispherical dome
    
    // Central hole dimensions
    hole_radius = 2.0;
    
    // Create hexagonal plate
    hex_plate = scale([1, 1, plate_thickness / 2])
        cylinder(r=hex_radius, h=1, $fn=6);
    
    // Create hemispherical dome
    dome = translate([0, 0, plate_thickness])
        sphere(r=dome_radius, $fn=64);
    
    // Create central hole
    central_hole = translate([0, 0, -1])
        cylinder(r=hole_radius, h=plate_thickness + dome_height + 2, $fn=64);
    
    // Combine all parts
    difference() {
        union() {
            hex_plate;
            dome;
        }
        central_hole;
    }
}

hex_plate_with_dome();