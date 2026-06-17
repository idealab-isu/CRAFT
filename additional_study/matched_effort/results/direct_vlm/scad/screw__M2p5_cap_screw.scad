$fn = 96;

d_shaft = 2.5;
L = 10;

d_head = 4.5;
h_head = 2.5;

// Approximate hex socket for this size
socket_af = 2.0;          // across flats
socket_depth = 1.6;
socket_corner_r = 0.15;

module hex_prism(af, h) {
    // Regular hex with given across-flats dimension
    r = af / sqrt(3); // circumradius
    linear_extrude(height = h)
        polygon([ for (i = [0:5]) [ r*cos(60*i), r*sin(60*i) ] ]);
}

module socket_head_cap_screw() {
    difference() {
        union() {
            // Shaft
            cylinder(d = d_shaft, h = L);

            // Head
            translate([0,0,L])
                cylinder(d = d_head, h = h_head);
        }

        // Hex socket cut
        translate([0,0,L + h_head - socket_depth])
            minkowski() {
                hex_prism(socket_af - 2*socket_corner_r, socket_depth);
                sphere(r = socket_corner_r);
            }
    }
}

socket_head_cap_screw();