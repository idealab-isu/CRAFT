$fn=96;

d_shaft = 3.0;
L = 10.0;

d_head = 5.5;
h_head = 3.0;

// Approximate hex socket for M3 socket head cap screw
socket_af = 2.5;          // across flats
socket_depth = 1.6;       // depth
socket_corner_r = 0.05;   // tiny rounding to avoid degeneracy

module hex_prism_af(af, h){
    // Regular hex with given across-flats dimension
    r = af / sqrt(3); // circumradius
    cylinder(h=h, r=r, $fn=6);
}

module socket_head_cap_screw(){
    difference(){
        union(){
            // Shaft (unthreaded approximation)
            cylinder(h=L, d=d_shaft);

            // Head
            translate([0,0,L])
                cylinder(h=h_head, d=d_head);
        }

        // Hex socket cut
        translate([0,0,L + h_head - socket_depth])
            minkowski(){
                hex_prism_af(socket_af - 2*socket_corner_r, socket_depth);
                sphere(r=socket_corner_r, $fn=24);
            }
    }
}

socket_head_cap_screw();