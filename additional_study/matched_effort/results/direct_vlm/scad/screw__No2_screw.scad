$fn = 96;

d_shaft = 2.2;
L = 10;

d_head = 4.2;
h_head = 1.7;

// Simple pan head approximation: short cylinder + spherical cap
module pan_head_screw(d_shaft, L, d_head, h_head) {
    union() {
        // Shaft
        cylinder(d = d_shaft, h = L);

        // Head base cylinder (small rim)
        head_rim_h = min(0.5, h_head * 0.35);
        translate([0,0,L])
            cylinder(d = d_head, h = head_rim_h);

        // Spherical cap for rounded top
        cap_h = h_head - head_rim_h;
        if (cap_h > 0) {
            // Sphere radius chosen so cap height = cap_h with base radius = d_head/2
            a = d_head/2;
            R = (a*a + cap_h*cap_h) / (2*cap_h);

            translate([0,0,L + head_rim_h])
                intersection() {
                    // Sphere centered so that z=0 plane cuts at the cap base
                    translate([0,0,R - cap_h]) sphere(r = R);
                    cylinder(d = d_head, h = cap_h);
                }
        }
    }
}

pan_head_screw(d_shaft, L, d_head, h_head);