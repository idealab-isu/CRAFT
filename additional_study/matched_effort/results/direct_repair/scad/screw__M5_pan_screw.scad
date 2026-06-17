$fn = 120;

shaft_d = 5.0;
length = 10.0;

head_d = 10.0;
head_h = 3.95;

// Simple pan head screw (no threads, no drive recess)
union() {
    // Shaft
    cylinder(d = shaft_d, h = length);

    // Pan head: cylindrical base + rounded dome
    translate([0,0,length]) {
        union() {
            // Cylindrical portion
            cylinder(d = head_d, h = head_h * 0.55);

            // Rounded top (spherical cap approximation)
            translate([0,0,head_h * 0.55])
                intersection() {
                    sphere(d = head_d);
                    translate([0,0,0])
                        cylinder(d = head_d, h = head_h * 0.45);
                }
        }
    }
}