$fn = 96;

// Socket head cap screw (approximate)
// Threaded shank: 2.0 mm diameter, 10 mm long
// Head: 3.8 mm diameter, 2.0 mm tall
// Hex socket: sized for ~1.5 mm Allen key (approx), with slight clearance

d_shank = 2.0;
L_shank = 10.0;

d_head  = 3.8;
h_head  = 2.0;

hex_key_af = 1.5;      // across flats (approx for M2)
hex_clear  = 0.10;     // clearance
socket_depth = 1.4;    // typical socket depth for small SHCS
socket_depth = min(socket_depth, h_head - 0.2);

module hex_prism(af, h){
    // Regular hex with given across-flats (af)
    // For a regular hex, circumradius R = af / sqrt(3)
    R = af / sqrt(3);
    cylinder(h=h, r=R, $fn=6);
}

module socket_head_cap_screw(){
    difference(){
        union(){
            // Shank
            cylinder(h=L_shank, d=d_shank);

            // Head on top of shank
            translate([0,0,L_shank])
                cylinder(h=h_head, d=d_head);
        }

        // Hex socket cut into head
        translate([0,0,L_shank + h_head - socket_depth])
            hex_prism(hex_key_af + hex_clear, socket_depth + 0.2);
    }
}

socket_head_cap_screw();