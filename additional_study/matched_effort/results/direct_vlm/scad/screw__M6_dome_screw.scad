$fn = 120;

// Dimensions (mm)
shaft_d = 6.0;
shaft_r = shaft_d/2;
length = 10.0;

head_d = 10.5;
head_r = head_d/2;
head_h = 3.3;

// Simple dome-head screw (unthreaded shank)
module dome_head_screw() {
    union() {
        // Shank
        cylinder(h = length, r = shaft_r);

        // Dome head: spherical cap blended to a short cylindrical collar
        translate([0,0,length]) {
            // Collar to ensure clean join at shank
            cylinder(h = 0.2, r = head_r);

            // Spherical cap sized to match head diameter and height
            // Sphere radius R = (a^2 + h^2) / (2h), where a=head_r, h=head_h
            R = (head_r*head_r + head_h*head_h) / (2*head_h);
            // Place sphere so that cap base is at z=0 and top at z=head_h
            translate([0,0,head_h - R])
                intersection() {
                    sphere(r = R);
                    translate([0,0,0])
                        cylinder(h = head_h, r = head_r);
                }
        }
    }
}

dome_head_screw();