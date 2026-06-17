$fn=128;

d_shaft = 6.0;
L = 10.0;

d_head = 10.5;
h_head = 3.3;

module dome_head_screw(d_shaft=6.0, L=10.0, d_head=10.5, h_head=3.3) {
    union() {
        // Shaft (cylindrical)
        cylinder(d=d_shaft, h=L);

        // Dome head: spherical cap blended to a short cylindrical collar
        // Place head on top of shaft (z from L to L+h_head)
        translate([0,0,L]) {
            // Spherical cap parameters
            // Choose sphere radius so that cap height = h_head and base radius = d_head/2
            a = d_head/2;
            h = h_head;
            R = (a*a + h*h) / (2*h);          // sphere radius
            zc = h - R;                       // sphere center z relative to cap base plane

            // Build cap by intersecting sphere with a limiting cylinder and half-space
            intersection() {
                // Limit to head diameter
                cylinder(d=d_head, h=h_head);
                // Sphere positioned so that cap height is h_head above base plane
                translate([0,0,zc]) sphere(r=R);
            }

            // Ensure a clean base ring at the head/shaft junction (tiny collar)
            // (helps avoid a razor-thin edge if dimensions are tight)
            collar_h = 0.2;
            cylinder(d=d_head, h=collar_h);
        }
    }
}

dome_head_screw(d_shaft=d_shaft, L=L, d_head=d_head, h_head=h_head);