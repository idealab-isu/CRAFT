$fn=96;

// Dimensions (mm)
shaft_d = 2.5;
length_total = 10.0;

head_d = 5.35;
head_h = 1.6;

// Derived
shaft_len = length_total - head_h;

module dome_head_screw() {
    union() {
        // Shaft (unthreaded)
        translate([0,0,-shaft_len])
            cylinder(h=shaft_len, d=shaft_d);

        // Dome head: spherical cap on top of a short cylinder base
        // Use a sphere of radius head_d/2, intersected with a slab of height head_h.
        // Place so the cap spans z=[0, head_h].
        intersection() {
            translate([0,0,head_d/2])
                sphere(d=head_d);
            cylinder(h=head_h, d=head_d);
        }
    }
}

dome_head_screw();