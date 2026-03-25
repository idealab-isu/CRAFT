module grub_screw() {
    difference() {
        // Main body of the screw
        cylinder(h=6, d=3, $fn=64);
        
        // Hex socket
        translate([0, 0, 1])
            cylinder(h=3, d=2, $fn=6);
    }
}

grub_screw();