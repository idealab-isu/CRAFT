$fn=96;

// Socket head cap screw (approximate)
// Dimensions (mm)
d_shaft = 2.0;
L = 10.0;

d_head = 3.8;
h_head = 2.0;          // typical for M2-ish socket head
socket_d = 1.5;        // hex socket across flats approx
socket_depth = 1.2;    // socket depth

// Helper: hex prism by across-flats
module hex_prism_af(af, h){
    // For a regular hexagon, circumradius R = af / sqrt(3)
    R = af / sqrt(3);
    cylinder(h=h, r=R, $fn=6);
}

module socket_head_cap_screw(){
    difference(){
        union(){
            // Shaft
            cylinder(h=L, d=d_shaft);

            // Head
            translate([0,0,L])
                cylinder(h=h_head, d=d_head);
        }

        // Hex socket cut
        translate([0,0,L + h_head - socket_depth])
            hex_prism_af(socket_d, socket_depth + 0.05);
    }
}

socket_head_cap_screw();