$fn = 96;

// Dimensions (mm)
shaft_d = 2.5;
length  = 10;

head_d  = 4.5;
head_h  = 2.5;

// Approximate hex socket dimensions for an M2.5 SHCS
socket_af = 2.0;   // across flats
socket_depth = 1.6;
socket_entry_chamfer = 0.25;

module hex_prism(af, h) {
    // Regular hex with across-flats = af
    r = af / sqrt(3); // circumradius
    cylinder(h = h, r = r, $fn = 6);
}

difference() {
    union() {
        // Shaft
        cylinder(h = length, d = shaft_d);

        // Head
        translate([0,0,length])
            cylinder(h = head_h, d = head_d);
    }

    // Hex socket cut
    translate([0,0,length + head_h - socket_depth])
        hex_prism(socket_af, socket_depth + 0.02);

    // Small entry chamfer to the socket
    translate([0,0,length + head_h - socket_depth - socket_entry_chamfer])
        cylinder(h = socket_entry_chamfer + 0.02, d1 = socket_af * 1.15, d2 = socket_af * 0.98, $fn = 48);
}