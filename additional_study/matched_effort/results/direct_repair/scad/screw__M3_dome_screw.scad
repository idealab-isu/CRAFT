$fn = 96;

// Dimensions (mm)
shaft_d = 3.0;
length  = 10.0;

head_d  = 5.7;
head_h  = 1.65;

// Simple dome-head screw (no threads, no drive)
module dome_head_screw(shaft_d, length, head_d, head_h) {
    union() {
        // Shaft
        cylinder(h = length, d = shaft_d);

        // Dome head: spherical cap blended to a short cylindrical rim
        // Choose a sphere radius that yields the desired cap height at the given base radius.
        base_r = head_d/2;
        cap_h  = head_h;
        R = (base_r*base_r + cap_h*cap_h) / (2*cap_h); // sphere radius for cap

        // Cylindrical rim (very small) to ensure clean union at the base
        rim_h = min(0.15, head_h*0.2);
        translate([0,0,length])
            cylinder(h = rim_h, d = head_d);

        // Spherical cap
        translate([0,0,length + (cap_h - R)])
            intersection() {
                sphere(r = R);
                translate([0,0,R - cap_h])
                    cylinder(h = cap_h, r = base_r);
            }
    }
}

dome_head_screw(shaft_d, length, head_d, head_h);