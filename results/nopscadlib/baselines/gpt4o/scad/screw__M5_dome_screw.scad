module dome_head_screw() {
    $fn = 64;
    // Screw head
    difference() {
        translate([0, 0, 10])
            cylinder(h = 2.75, d1 = 9.5, d2 = 0, center = true);
        translate([0, 0, 10])
            cylinder(h = 2.75, d = 5.0, center = true);
    }
    // Screw body
    translate([0, 0, 5])
        cylinder(h = 10, d = 5.0, center = true);
}

dome_head_screw();