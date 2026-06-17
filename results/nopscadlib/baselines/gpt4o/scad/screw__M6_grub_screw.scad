module grub_screw() {
    $fn = 64;
    // Main body of the screw
    cylinder(h = 6, d = 6, center = true);
    
    // Hex socket
    translate([0, 0, 3])
        rotate([0, 0, 0])
            difference() {
                cylinder(h = 3, d = 4, center = true);
                rotate([0, 0, 0])
                    translate([0, 0, 1.5])
                        cylinder(h = 3, d = 3, center = true);
            }
}

grub_screw();