$fn = 96;

d_shaft = 3.0;
L = 10.0;

d_head = 5.5;
h_head = 2.0;

hex_flat = 2.5;          // approximate for M3 socket
hex_depth = 1.5;         // approximate socket depth
chamfer = 0.25;

module socket_head_cap_screw() {
    difference() {
        union() {
            // Shaft
            translate([0,0,-L])
                cylinder(d=d_shaft, h=L);

            // Head (slight top chamfer)
            cylinder(d=d_head, h=h_head);
            translate([0,0,h_head - chamfer])
                cylinder(d1=d_head, d2=d_head - 2*chamfer, h=chamfer);
        }

        // Hex socket
        translate([0,0,h_head - hex_depth])
            cylinder(h=hex_depth + 0.02, d=hex_flat / cos(30), $fn=6);
    }
}

socket_head_cap_screw();