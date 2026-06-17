$fn = 120;

// Dimensions (mm)
shaft_d = 3.0;
shaft_r = shaft_d/2;

length = 10.0;          // under-head length
head_d = 5.7;
head_r = head_d/2;
head_h = 1.65;

// Simple dome-head approximation: cylindrical skirt + spherical cap
skirt_h = min(0.35*head_h, 0.6);   // small straight section
cap_h   = head_h - skirt_h;

// Spherical cap radius chosen so cap base radius = head_r and cap height = cap_h
cap_R = (head_r*head_r + cap_h*cap_h) / (2*cap_h);

module dome_head_screw() {
    union() {
        // Shaft (unthreaded)
        cylinder(h=length, r=shaft_r);

        // Head: skirt
        translate([0,0,length])
            cylinder(h=skirt_h, r=head_r);

        // Head: spherical cap
        translate([0,0,length + skirt_h])
            intersection() {
                // Sphere positioned so its cap height above z=0 is cap_h
                translate([0,0,cap_R - cap_h])
                    sphere(r=cap_R);
                // Keep only the cap portion
                cylinder(h=cap_h, r=head_r);
            }
    }
}

dome_head_screw();