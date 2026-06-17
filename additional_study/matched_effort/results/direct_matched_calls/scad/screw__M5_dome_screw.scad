$fn = 120;

shaft_d = 5.0;
head_d  = 9.5;
head_h  = 2.75;
len     = 10.0;

module dome_head_screw(shaft_d=5, head_d=9.5, head_h=2.75, len=10) {
    union() {
        // Shaft (unthreaded)
        cylinder(d=shaft_d, h=len, center=false);

        // Dome head: spherical cap blended to a short cylindrical skirt
        translate([0,0,len]) {
            union() {
                // Small cylindrical skirt to ensure clean join at the base
                skirt_h = min(0.35, head_h*0.2);
                cylinder(d=head_d, h=skirt_h, center=false);

                // Spherical cap for dome
                cap_h = head_h - skirt_h;
                if (cap_h > 0) {
                    R = (cap_h*cap_h + (head_d/2)*(head_d/2)) / (2*cap_h);
                    zc = cap_h - R; // sphere center relative to cap base plane (z=0)
                    intersection() {
                        translate([0,0,zc]) sphere(r=R);
                        cylinder(d=head_d, h=cap_h, center=false);
                    }
                }
            }
        }
    }
}

dome_head_screw(shaft_d, head_d, head_h, len);