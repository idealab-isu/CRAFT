$fn = 128;

// Parameters (mm)
shaft_d = 5.0;
length = 10.0;

head_d = 10.0;
head_h = 3.95;

// Simple pan head approximation: cylindrical head with a rounded top
module pan_head_screw(shaft_d, length, head_d, head_h) {
    union() {
        // Shaft
        cylinder(d = shaft_d, h = length);

        // Head (cylinder + spherical cap)
        translate([0, 0, length]) {
            union() {
                // Main head cylinder (leave some height for the dome)
                dome_h = min(head_h * 0.45, head_h - 0.2);
                cyl_h  = head_h - dome_h;

                cylinder(d = head_d, h = cyl_h);

                // Rounded top via intersection with a sphere (spherical cap)
                translate([0, 0, cyl_h]) {
                    // Choose a sphere radius that gives a gentle dome
                    R = head_d * 0.75;
                    intersection() {
                        translate([0, 0, R - dome_h])
                            sphere(r = R);
                        cylinder(d = head_d, h = dome_h);
                    }
                }
            }
        }
    }
}

pan_head_screw(shaft_d, length, head_d, head_h);