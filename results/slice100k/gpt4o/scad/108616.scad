module paddle_plate() {
    difference() {
        union() {
            // Rounded rectangle head
            translate([-36.5, 0, 0])
            minkowski() {
                cube([50, 20, 4], center = true);
                cylinder(r = 2, h = 4, $fn = 64);
            }
            // Tapered neck
            translate([-11.5, 0, 0])
            linear_extrude(height = 4)
            polygon(points = [[0, -10], [0, 10], [10, 5], [10, -5]]);
            // Rectangular handle/shaft
            translate([0, -5, 0])
            cube([23, 10, 4], center = true);
        }
        // Rectangular window cutout
        translate([-11.5, 0, 0])
        cube([30, 10, 4], center = true);
    }
    // Circular through-holes
    translate([-26.5, 5, 0])
    cylinder(r = 1.5, h = 4, center = true, $fn = 64);
    translate([-26.5, -5, 0])
    cylinder(r = 1.5, h = 4, center = true, $fn = 64);
}

paddle_plate();