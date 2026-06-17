$fn = 160;

// Main straight pipe body (hollow)
module ht_pipe_body(length, outer_diameter, wall_thickness) {
    difference() {
        cylinder(h=length, d=outer_diameter, center=false);
        translate([0, 0, -0.5])
            cylinder(h=length + 1, d=outer_diameter - 2*wall_thickness, center=false);
    }
}

// Socket/bell end (hollow sleeve). Built so its Z=0 face is the "attach plane".
// It extends DOWN by 'overlap' to guarantee intersection with the pipe end.
module socket_end(outer_diameter, wall_thickness, socket_len, socket_wall_extra, overlap) {
    inner_d = outer_diameter - 2*wall_thickness;
    outer_socket_d = outer_diameter + 2*socket_wall_extra;

    difference() {
        // Outer sleeve: from z=-overlap to z=socket_len
        translate([0, 0, -overlap])
            cylinder(h=socket_len + overlap, d=outer_socket_d, center=false);

        // Bore: keep hollow through entire sleeve
        translate([0, 0, -overlap - 0.5])
            cylinder(h=socket_len + overlap + 1, d=inner_d, center=false);
    }
}

module ht_pipe() {
    outer_diameter = 160;     // mm
    wall_thickness = 3.2;     // mm
    length = 500;             // mm

    socket_len = 40;          // mm
    socket_wall_extra = 3.0;  // mm
    overlap = 2;              // mm (1-2mm required)

    union() {
        // Pipe body from z=0..length
        ht_pipe_body(length, outer_diameter, wall_thickness);

        // Top socket: attach plane at z=length, sleeve overlaps down into pipe by 'overlap'
        translate([0, 0, length])
            socket_end(outer_diameter, wall_thickness, socket_len, socket_wall_extra, overlap);

        // Bottom socket: attach plane at z=0, sleeve overlaps up into pipe by 'overlap'
        mirror([0, 0, 1])
            socket_end(outer_diameter, wall_thickness, socket_len, socket_wall_extra, overlap);
    }
}

ht_pipe();