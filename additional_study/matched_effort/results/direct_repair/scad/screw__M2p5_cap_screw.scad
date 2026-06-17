$fn = 96;

shaft_d = 2.5;
length = 10;

head_d = 4.5;
head_h = 2.5;

// Approximate hex socket for M2.5: 2.0mm across flats, depth ~1.5mm
socket_af = 2.0;
socket_depth = 1.5;

module hex_prism(af, h) {
    // Regular hex with across-flats = af => circumradius = af / sqrt(3)
    r = af / sqrt(3);
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
        hex_prism(socket_af, socket_depth + 0.01);
}