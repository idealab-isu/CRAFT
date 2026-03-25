module dome_head_screw() {
    $fn = 64;
    // Screw head
    translate([0, 0, 10])
    union() {
        // Dome part of the head
        translate([0, 0, 3.3])
        sphere(d = 10.5);
        // Cylindrical part of the head
        cylinder(h = 3.3, d = 10.5);
    }
    // Screw shaft
    translate([0, 0, 0])
    cylinder(h = 10, d = 6);
}

dome_head_screw();