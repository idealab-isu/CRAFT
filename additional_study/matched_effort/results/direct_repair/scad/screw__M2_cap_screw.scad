$fn = 96;

// Dimensions (mm)
shaft_d = 2.0;
length  = 10.0;

head_d  = 3.8;
head_h  = 2.0;

// Socket (hex) approximation for a 2mm screw (M2 typical)
socket_af = 1.5;          // across flats
socket_depth = 1.2;       // depth into head
socket_corner_r = socket_af / sqrt(3); // circumradius for hex

module hex_prism(r, h) {
    cylinder(r = r, h = h, $fn = 6);
}

module socket_head_cap_screw() {
    difference() {
        union() {
            // Shaft
            cylinder(d = shaft_d, h = length);

            // Head
            translate([0,0,length])
                cylinder(d = head_d, h = head_h);
        }

        // Hex socket cut
        translate([0,0,length + head_h - socket_depth])
            hex_prism(socket_corner_r, socket_depth + 0.05);
    }
}

socket_head_cap_screw();