module flanged_spacer() {
    $fn = 64;
    shaft_length = 40;
    shaft_radius = 10;
    collar_thickness = 10;
    collar_flat_distance = 30; // Distance across flats of the hexagon

    // Calculate the radius of the circumscribed circle of the hexagon
    collar_radius = collar_flat_distance / (2 * cos(30));

    // Shaft
    cylinder(h = shaft_length, r = shaft_radius, center = true);

    // Hexagonal collar
    translate([0, 0, 0])
    rotate([0, 0, 0])
    linear_extrude(height = collar_thickness, center = true)
    polygon(points = [
        [collar_flat_distance / 2, 0],
        [collar_flat_distance / 4, collar_radius],
        [-collar_flat_distance / 4, collar_radius],
        [-collar_flat_distance / 2, 0],
        [-collar_flat_distance / 4, -collar_radius],
        [collar_flat_distance / 4, -collar_radius]
    ]);
}

flanged_spacer();