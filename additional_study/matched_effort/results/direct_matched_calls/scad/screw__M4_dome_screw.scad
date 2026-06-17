$fn = 120;

// Dimensions (mm)
shaft_d = 4.0;
shaft_r = shaft_d/2;

length_total = 10.0;

head_d = 7.6;
head_r = head_d/2;
head_h = 2.2;

// Simple dome-head screw (unthreaded shaft)
module dome_head_screw() {
    union() {
        // Shaft (under-head length)
        cylinder(h = length_total, r = shaft_r);

        // Dome head: spherical cap blended to a short cylindrical collar
        // Use a sphere cap whose base radius matches head_r and height matches head_h.
        // For a spherical cap: a = sqrt(2Rh - h^2) => R = (a^2 + h^2)/(2h)
        R = (head_r*head_r + head_h*head_h) / (2*head_h);

        // Place sphere so that the cap spans z = length_total .. length_total + head_h
        translate([0,0,length_total + (head_h - R)])
        intersection() {
            sphere(r = R);
            translate([0,0,R - head_h])
                cylinder(h = head_h, r = head_r);
        }
    }
}

dome_head_screw();