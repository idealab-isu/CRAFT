$fn = 128;

module ht_pipe_segment(length = 1000, diameter = 110) {
    wall_thickness = 3.2;          // typical HT 110 wall
    socket_len     = 50;           // end fitting length
    socket_extra_d = 10;           // socket OD increase
    overlap        = 1;            // ensure watertight union/difference

    union() {
        // Main pipe (hollow)
        ht_pipe(diameter = diameter, length = length, wall = wall_thickness);

        // End socket (hollow) connected to +Z end of pipe
        end_socket(
            pipe_diameter   = diameter,
            pipe_wall       = wall_thickness,
            socket_length   = socket_len,
            socket_extra_d  = socket_extra_d,
            pipe_length     = length,
            overlap         = overlap
        );
    }
}

module ht_pipe(diameter, length, wall) {
    outer_d = diameter;
    inner_d = outer_d - 2 * wall;
    difference() {
        cylinder(d = outer_d, h = length, center = true);
        cylinder(d = inner_d, h = length + 2, center = true); // +2 ensures full cut-through
    }
}

module end_socket(pipe_diameter, pipe_wall, socket_length, socket_extra_d, pipe_length, overlap) {
    socket_od = pipe_diameter + socket_extra_d;
    socket_id = socket_od - 2 * pipe_wall;

    // Place socket so it overlaps the pipe end by 'overlap'
    translate([0, 0, pipe_length/2 - overlap])
        difference() {
            cylinder(d = socket_od, h = socket_length + overlap, center = false);
            translate([0, 0, -1])
                cylinder(d = socket_id, h = socket_length + overlap + 2, center = false);
        }
}

ht_pipe_segment();