module socket_head_cap_screw() {
    // Parameters
    shaft_diameter = 2.0;
    head_diameter = 3.8;
    shaft_length = 10;
    head_height = 2.0; // Typical height for a socket head cap screw
    hex_socket_diameter = 1.5; // Approximate size for the hex socket
    hex_socket_depth = 1.5; // Depth of the hex socket

    // Shaft
    shaft = cylinder(d=shaft_diameter, h=shaft_length, $fn=64);

    // Head
    head = cylinder(d=head_diameter, h=head_height, $fn=64);

    // Hex socket
    hex_socket = translate([0, 0, head_height - hex_socket_depth])
                 cylinder(d=hex_socket_diameter, h=hex_socket_depth, $fn=6);

    // Combine head and shaft, subtract hex socket
    screw = union() {
        translate([0, 0, shaft_length]) head;
        shaft;
    }

    difference() {
        screw;
        hex_socket;
    }
}

socket_head_cap_screw();