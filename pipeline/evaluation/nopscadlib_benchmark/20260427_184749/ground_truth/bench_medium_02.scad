// MGN12 Linear Rail Carriage Mount
// MGN12H: 27mm x 42mm footprint, M3 mounting holes
carriage_width = 27;
carriage_length = 42;
hole_spacing_x = 20;
hole_spacing_y = 15;
mount_thickness = 6;

difference() {
    // Base block
    cube([carriage_width + 10, carriage_length + 10, mount_thickness], center=true);

    // MGN12H mounting holes pattern
    for (x = [-1, 1]) {
        for (y = [-1, 1]) {
            translate([x * hole_spacing_x/2, y * hole_spacing_y/2, 0])
                cylinder(d=3.2, h=mount_thickness+1, center=true, $fn=32);
        }
    }

    // Weight reduction slots
    for (y = [-1, 1]) {
        translate([0, y * (carriage_length/2 + 2), 0])
            cube([carriage_width - 4, 4, mount_thickness+1], center=true);
    }
}
