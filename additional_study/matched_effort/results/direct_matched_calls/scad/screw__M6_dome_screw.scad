$fn = 120;

// Parameters (mm)
shaft_d = 6.0;
shaft_r = shaft_d/2;

head_d = 10.5;
head_r = head_d/2;

head_h = 3.3;
length_under_head = 10.0;

// Simple dome-head screw (unthreaded shank)
module dome_head_screw() {
    union() {
        // Shank (under head)
        translate([0,0,-length_under_head])
            cylinder(h=length_under_head, r=shaft_r);

        // Head: cylindrical base + spherical cap to form a dome
        // Choose a sphere radius that yields a cap height of (head_h - base_h)
        base_h = 1.0; // small cylindrical land under the dome
        cap_h  = max(0.01, head_h - base_h);

        // Spherical cap geometry:
        // For a sphere of radius R, cap height h, base radius a:
        // a^2 = 2Rh - h^2  => R = (a^2 + h^2)/(2h)
        a = head_r;
        R = (a*a + cap_h*cap_h) / (2*cap_h);
        zc = base_h + (cap_h - R); // sphere center z so cap top is at z=base_h+cap_h

        // Cylindrical base of head
        cylinder(h=base_h, r=head_r);

        // Dome cap (intersection of sphere with a cylinder to keep diameter)
        intersection() {
            translate([0,0,zc]) sphere(r=R);
            cylinder(h=head_h, r=head_r);
        }
    }
}

dome_head_screw();