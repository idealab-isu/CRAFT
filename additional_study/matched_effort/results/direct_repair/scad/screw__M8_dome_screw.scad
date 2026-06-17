$fn=160;

d_shank = 8.0;
L = 10.0;

d_head = 14.0;
h_head = 4.4;

module dome_head_screw(d_shank=8.0, L=10.0, d_head=14.0, h_head=4.4) {
    union() {
        // Shank
        cylinder(h=L, d=d_shank);

        // Dome head (spherical cap) sitting on top of shank
        // Sphere radius chosen so that cap height = h_head and base radius = d_head/2
        r_base = d_head/2;
        R = (r_base*r_base + h_head*h_head) / (2*h_head); // sphere radius
        zc = L + (h_head - R); // sphere center z so that cap top is at L+h_head and base plane at z=L

        intersection() {
            translate([0,0,zc]) sphere(r=R);
            translate([0,0,L]) cylinder(h=h_head, r=r_base);
        }
    }
}

dome_head_screw(d_shank=d_shank, L=L, d_head=d_head, h_head=h_head);