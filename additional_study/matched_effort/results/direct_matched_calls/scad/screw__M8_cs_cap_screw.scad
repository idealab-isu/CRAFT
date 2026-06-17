$fn=96;

d_shaft = 8.0;
L = 10.0;

d_head = 16.0;
h_head = 8.0;

d_socket = 8.0;
depth_socket = 5.0;

module socket_head_cap_screw() {
    union() {
        // Shaft
        cylinder(d=d_shaft, h=L);

        // Head
        translate([0,0,L])
            cylinder(d=d_head, h=h_head);

        // Hex socket (subtracted)
        difference() {
            // no-op solid to subtract from: head only
            translate([0,0,L])
                cylinder(d=d_head, h=h_head);
            // hex recess
            translate([0,0,L + h_head - depth_socket])
                cylinder(d=d_socket, h=depth_socket + 0.2, $fn=6);
        }
    }
}

socket_head_cap_screw();