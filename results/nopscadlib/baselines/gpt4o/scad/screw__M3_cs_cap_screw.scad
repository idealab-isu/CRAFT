module socket_head_cap_screw() {
    // Screw dimensions
    screw_diameter = 3.0;
    screw_length = 10.0;
    head_diameter = 6.0;
    head_height = 3.0;
    hex_socket_diameter = 2.0;
    hex_socket_depth = 1.5;

    // Screw body
    cylinder(d=screw_diameter, h=screw_length, $fn=64);

    // Head
    translate([0, 0, screw_length])
        cylinder(d=head_diameter, h=head_height, $fn=64);

    // Hex socket
    translate([0, 0, screw_length + head_height - hex_socket_depth])
        cylinder(d=hex_socket_diameter, h=hex_socket_depth, $fn=6);
}

socket_head_cap_screw();