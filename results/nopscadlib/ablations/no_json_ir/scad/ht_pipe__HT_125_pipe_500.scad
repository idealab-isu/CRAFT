$fn = 128;

module ht_pipe_segment(length = 500) {
    ht_pipe(diameter = 125, length = length);
}

module ht_pipe(diameter, length) {
    outer_d = diameter;
    wall_t  = 3.2;                 // typical HT wall thickness (approx)
    inner_d = outer_d - 2*wall_t;

    socket_len = 20;               // end fitting length
    socket_d   = diameter + 10;    // end fitting outer diameter
    overlap    = 1;                // small overlap to guarantee union

    // Build as ONE connected solid: outer union minus inner voids
    difference() {
        union() {
            // Main outer pipe body
            cylinder(d = outer_d, h = length, center = true);

            // Top socket (connected by overlap)
            translate([0, 0, length/2 - overlap + socket_len/2])
                cylinder(d = socket_d, h = socket_len, center = true);

            // Bottom socket (connected by overlap)
            translate([0, 0, -length/2 + overlap - socket_len/2])
                cylinder(d = socket_d, h = socket_len, center = true);
        }

        // Main inner bore (through entire pipe)
        cylinder(d = inner_d, h = length + 0.2, center = true);

        // Socket inner reliefs (keep wall thickness consistent inside sockets)
        translate([0, 0, length/2 - overlap + socket_len/2])
            cylinder(d = inner_d, h = socket_len + 0.2, center = true);

        translate([0, 0, -length/2 + overlap - socket_len/2])
            cylinder(d = inner_d, h = socket_len + 0.2, center = true);
    }
}

ht_pipe_segment(500);