$fn = 96;

// Dimensions (mm)
shaft_d = 2.0;
length  = 10.0;

head_d  = 3.5;
head_h  = 1.3;

// Simple dome-head screw (unthreaded shaft)
module dome_head_screw(shaft_d, length, head_d, head_h) {
    union() {
        // Shaft
        cylinder(d = shaft_d, h = length);

        // Dome head: spherical cap blended to a short cylindrical collar
        // Choose a sphere radius that yields the desired cap height at base radius head_d/2
        r_base = head_d/2;
        h_cap  = head_h;

        // Sphere radius for a cap of height h_cap over base radius r_base:
        // R = (r_base^2 + h_cap^2) / (2*h_cap)
        R = (r_base*r_base + h_cap*h_cap) / (2*h_cap);

        // Place sphere so that the cap base plane is at z = length
        // Sphere center is at z = length + (h_cap - R)
        translate([0,0,length + (h_cap - R)])
            intersection() {
                sphere(r = R);
                // Keep only the cap above the base plane and within head diameter
                translate([0,0,length])
                    cylinder(r = r_base, h = h_cap);
            }

        // Small collar to ensure clean union at the base plane (very thin)
        translate([0,0,length - 0.01])
            cylinder(d = head_d, h = 0.02);
    }
}

dome_head_screw(shaft_d, length, head_d, head_h);