$fn = 128;

d_shaft = 8.0;
L = 10.0;

d_head = 13.0;
h_head = 8.0;

// Approximate hex socket dimensions for an M8 socket head cap screw
socket_af = 6.0;          // across flats
socket_depth = 5.0;       // depth of hex recess
socket_chamfer = 0.6;     // small entry chamfer

module hex_prism(af, h) {
    // Regular hex with across-flats = af
    r = af / sqrt(3); // circumradius
    cylinder(h=h, r=r, $fn=6);
}

module socket_head_cap_screw() {
    difference() {
        union() {
            // Shaft
            cylinder(h=L, d=d_shaft);

            // Head
            translate([0,0,L])
                cylinder(h=h_head, d=d_head);
        }

        // Hex socket recess
        translate([0,0,L + h_head - socket_depth])
            hex_prism(socket_af, socket_depth + 0.02);

        // Entry chamfer (simple conical lead-in)
        translate([0,0,L + h_head - socket_depth - 0.01])
            cylinder(h=socket_chamfer + 0.02, d1=socket_af*1.25, d2=socket_af*1.02, $fn=64);
    }
}

socket_head_cap_screw();