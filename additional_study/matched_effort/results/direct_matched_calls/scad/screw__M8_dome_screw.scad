$fn=128;

d_shank = 8.0;
L = 10.0;

d_head = 14.0;
h_head = 4.4;

module dome_head_screw(d_shank=8.0, L=10.0, d_head=14.0, h_head=4.4) {
    union() {
        // Shank
        cylinder(h=L, d=d_shank);

        // Dome head (spherical cap) sitting on top of shank
        translate([0,0,L]) {
            // Spherical cap parameters
            a = d_head/2;          // base radius
            h = h_head;            // cap height
            R = (a*a + h*h)/(2*h); // sphere radius producing cap
            zc = h - R;            // sphere center z relative to cap base plane

            intersection() {
                // Sphere that defines the dome
                translate([0,0,zc]) sphere(r=R);

                // Limit to cap height
                cylinder(h=h, r=a);
            }
        }
    }
}

dome_head_screw(d_shank, L, d_head, h_head);