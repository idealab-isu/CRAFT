$fn = 120;

// Parameters (mm)
shaft_d = 4.0;
shaft_r = shaft_d/2;

head_d = 7.6;
head_r = head_d/2;

head_h = 2.2;
length = 10.0;          // total length including head
shaft_len = length - head_h;

module dome_head_screw() {
    union() {
        // Shaft (unthreaded)
        translate([0,0,0])
            cylinder(h = shaft_len, r = shaft_r);

        // Dome head: spherical cap blended to a short cylindrical collar
        translate([0,0,shaft_len]) {
            // Collar to ensure clean join at head base
            cylinder(h = 0.25, r = head_r);

            // Spherical cap sized to match head diameter and height
            // Sphere radius R = (a^2 + h^2) / (2h), where a=head_r, h=head_h
            R = (head_r*head_r + head_h*head_h) / (2*head_h);
            zc = head_h - R; // sphere center relative to head base plane

            intersection() {
                translate([0,0,zc]) sphere(r = R);
                cylinder(h = head_h, r = head_r);
            }
        }
    }
}

dome_head_screw();