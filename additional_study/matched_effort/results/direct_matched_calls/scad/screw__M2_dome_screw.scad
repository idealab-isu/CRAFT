$fn = 96;

// Dimensions (mm)
shaft_d = 2.0;
shaft_r = shaft_d/2;

length = 10.0;          // under-head length
head_d = 3.5;
head_r = head_d/2;
head_h = 1.3;

// Simple dome-head screw (no threads, no drive)
module dome_head_screw() {
    union() {
        // Shaft
        cylinder(h = length, r = shaft_r);

        // Head: cylindrical base + spherical cap to form a dome
        translate([0,0,length]) {
            union() {
                // Base cylinder (keeps full head diameter at the bottom)
                cylinder(h = head_h*0.35, r = head_r);

                // Spherical cap (dome)
                // Choose sphere radius so cap height equals remaining head height
                cap_h = head_h*0.65;
                R = (head_r*head_r + cap_h*cap_h) / (2*cap_h); // sphere radius for given base radius and cap height
                // Place sphere so that the cap starts at z = base cylinder top
                translate([0,0,head_h*0.35 + (cap_h - R)])
                    sphere(r = R);
            }
        }
    }
}

dome_head_screw();