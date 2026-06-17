$fn = 96;

module metric_socket_head_cap_screw(
    shank_d = 4.0,
    length  = 10.0,   // under-head length
    head_d  = 7.0,
    head_h  = 4.0,
    socket_af = 3.0,  // across flats (approx for M4)
    socket_depth = 2.5,
    socket_chamfer = 0.4
) {
    // One connected solid: head + shank, with socket subtracted from head
    difference() {
        union() {
            // Shank: z = 0 .. length
            cylinder(h = length, d = shank_d, center = false);

            // Head: sits on top of shank, z = length .. length+head_h
            translate([0, 0, length])
                cylinder(h = head_h, d = head_d, center = false);
        }

        // Hex/Allen socket cut into head from the top
        translate([0, 0, length + head_h])
            hex_socket_cut(af = socket_af, depth = socket_depth, chamfer = socket_chamfer);
    }
}

module hex_socket_cut(af, depth, chamfer) {
    // Cut downward from z=0 (top surface) into the head
    // Includes a small entry chamfer for a more realistic socket
    union() {
        // Main hex pocket
        translate([0, 0, -depth])
            linear_extrude(height = depth + 0.01)
                polygon(points = hex_points_from_af(af));

        // Entry chamfer (slight taper)
        translate([0, 0, -chamfer])
            linear_extrude(height = chamfer + 0.01, scale = (af + 2*chamfer)/af)
                polygon(points = hex_points_from_af(af));
    }
}

function hex_points_from_af(af) =
    let(R = af / sqrt(3))  // circumradius from across-flats
    [ for (i = [0:5]) [ R * cos(30 + i*60), R * sin(30 + i*60) ] ];

metric_socket_head_cap_screw();