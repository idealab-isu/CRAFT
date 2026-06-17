$fn = 128;

// Dimensions (mm)
d_shaft = 5.0;     // major diameter
L = 10.0;          // length under head
d_head = 8.5;      // head diameter
h_head = 5.0;      // head height

// Hex socket (approx for M5 socket head cap screw)
socket_af = 4.0;       // across flats
socket_depth = 3.0;    // depth into head

// Thread approximation (visual)
thread_pitch = 0.8;    // M5 coarse
thread_depth = 0.35;   // radial depth (approx)
thread_fn = 24;        // resolution for thread helix

eps = 0.02;

module hex_prism(af, h) {
    // Regular hex with given across-flats dimension
    r = af / sqrt(3); // circumradius
    cylinder(h = h, r = r, $fn = 6);
}

module threaded_shaft(d_major, len, pitch, depth, fn=24) {
    // Approximate external thread by helical subtraction from a major-diameter cylinder
    r_major = d_major/2;
    r_minor = r_major - depth;

    difference() {
        cylinder(h = len, r = r_major);

        linear_extrude(height = len + 2*eps,
                      twist  = -360 * (len / pitch),
                      slices = max(ceil((len/pitch) * fn), 24),
                      convexity = 10)
            translate([r_minor, 0, 0])
                circle(r = depth, $fn = fn);
    }
}

module socket_head_cap_screw() {
    // Build with head at Z=[0..h_head], shank at Z=[-L..0]
    difference() {
        union() {
            // Head
            cylinder(h = h_head, d = d_head);

            // Threaded shank (overlap into head by eps to ensure one connected solid)
            translate([0, 0, -L - eps])
                threaded_shaft(d_shaft, L + eps, thread_pitch, thread_depth, thread_fn);
        }

        // Hex socket cut from top of head
        translate([0, 0, h_head - socket_depth])
            hex_prism(socket_af, socket_depth + eps);
    }
}

socket_head_cap_screw();