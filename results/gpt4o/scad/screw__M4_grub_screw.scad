module grub_screw() {
    $fn = 64;
    // Main body of the screw
    cylinder(h = 4, d = 4, center = true);
    
    // Hex socket
    translate([0, 0, 2])
        difference() {
            cylinder(h = 2, d = 2.5, center = true);
            rotate([0, 0, 0])
                translate([0, 0, -1])
                    cylinder(h = 4, d = 1.5, center = true);
        }
}

grub_screw();