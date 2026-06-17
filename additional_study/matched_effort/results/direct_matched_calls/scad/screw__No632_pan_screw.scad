$fn = 96;

shaft_d = 3.5;
length = 10;

head_d = 6.9;
head_h = 2.5;

// Simple pan head approximation: cylindrical skirt + spherical cap
skirt_h = head_h * 0.55;
cap_h   = head_h - skirt_h;

module pan_head_screw(shaft_d, length, head_d, head_h) {
    skirt_h = head_h * 0.55;
    cap_h   = head_h - skirt_h;

    union() {
        // Shaft
        cylinder(d=shaft_d, h=length);

        // Head skirt
        translate([0,0,length])
            cylinder(d=head_d, h=skirt_h);

        // Head dome (spherical cap)
        // Sphere radius chosen so that cap height = cap_h and base radius = head_d/2
        r_base = head_d/2;
        R = (r_base*r_base + cap_h*cap_h) / (2*cap_h);

        translate([0,0,length + skirt_h])
            intersection() {
                translate([0,0,R - cap_h]) sphere(r=R);
                cylinder(d=head_d, h=cap_h);
            }
    }
}

pan_head_screw(shaft_d, length, head_d, head_h);