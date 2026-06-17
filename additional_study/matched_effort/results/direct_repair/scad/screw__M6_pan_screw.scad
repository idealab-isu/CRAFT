$fn = 128;

// Parameters (mm)
shaft_d = 6.0;
shaft_r = shaft_d/2;

head_d = 12.0;
head_r = head_d/2;

head_h = 4.75;
shaft_len = 10.0;

// Simple pan head profile: cylindrical skirt + rounded dome
skirt_h = head_h * 0.55;
dome_h  = head_h - skirt_h;

module pan_head_screw() {
    union() {
        // Shaft (unthreaded)
        translate([0,0,-shaft_len])
            cylinder(h=shaft_len, r=shaft_r);

        // Head skirt
        cylinder(h=skirt_h, r=head_r);

        // Head dome (spherical cap approximation)
        // Sphere radius chosen so that cap height = dome_h and base radius = head_r
        // R = (a^2 + h^2) / (2h)
        dome_R = (head_r*head_r + dome_h*dome_h) / (2*dome_h);

        translate([0,0,skirt_h])
            intersection() {
                // Sphere positioned so its cap starts at z=0 and rises to z=dome_h
                translate([0,0,dome_R - dome_h])
                    sphere(r=dome_R);
                cylinder(h=dome_h, r=head_r);
            }

        // Small fillet at head/shaft junction (optional subtle blend)
        // Keeps render robust without changing nominal dimensions much.
        translate([0,0,0])
            cylinder(h=0.4, r1=shaft_r, r2=head_r);
    }
}

pan_head_screw();