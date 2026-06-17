$fn=96;

d_shaft = 6.0;
L = 10.0;

d_head = 10.0;
h_head = 6.0;

// Approximate hex socket dimensions for an M6 socket head cap screw
socket_af = 5.0;          // across flats
socket_depth = 4.0;       // depth
socket_corner_r = 0.25;   // slight rounding

module hex_prism(af, h){
    // Regular hex with across-flats = af
    r = af / sqrt(3); // circumradius
    cylinder(h=h, r=r, $fn=6);
}

module socket_head_cap_screw(){
    difference(){
        union(){
            // Shaft
            translate([0,0,0])
                cylinder(h=L, d=d_shaft);

            // Head on top of shaft
            translate([0,0,L])
                cylinder(h=h_head, d=d_head);
        }

        // Hex socket cut into head from top
        translate([0,0,L + h_head - socket_depth])
            minkowski(){
                hex_prism(socket_af - 2*socket_corner_r, socket_depth);
                sphere(r=socket_corner_r, $fn=24);
            }
    }
}

socket_head_cap_screw();