module grub_screw() {
    $fn = 64;
    // Main body of the grub screw
    cylinder(h = 5, d = 5, center = true);
    
    // Hex socket
    translate([0, 0, 2.5])
        difference() {
            cylinder(h = 2.5, d = 3, center = true);
            rotate([0, 0, 0])
                translate([0, 0, -1.25])
                cylinder(h = 2.5, d = 2.5, center = true);
        }
}

grub_screw();