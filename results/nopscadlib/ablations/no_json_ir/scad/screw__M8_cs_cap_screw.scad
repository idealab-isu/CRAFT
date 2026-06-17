$fn = 120;

module socket_head_cap_screw(
    shank_d = 8.0,
    shank_l = 10.0,     // under-head length
    head_d  = 16.0,
    head_h  = 6.0,
    socket_af = 6.0,    // hex across flats (approx for M8)
    socket_depth = 4.0,
    thread_pitch = 1.25,
    thread_depth = 0.6
) {
    eps = 0.05;

    // Ensure valid geometry
    socket_depth_c = min(socket_depth, head_h - eps);
    thread_depth_c = min(thread_depth, shank_d/2 - eps);

    union() {
        // Shank (threaded approximation), from z=0 to z=shank_l
        threaded_shank(d = shank_d, l = shank_l, pitch = thread_pitch, depth = thread_depth_c);

        // Head sits directly on top of shank: from z=shank_l to z=shank_l+head_h
        translate([0, 0, shank_l - eps])  // small overlap to guarantee one connected solid
        difference() {
            cylinder(h = head_h + eps, d = head_d);

            // Hex socket recess from top face downward
            translate([0, 0, head_h - socket_depth_c])
                cylinder(h = socket_depth_c + 2*eps, d = socket_af / cos(30), $fn = 6);
        }
    }
}

module threaded_shank(d = 8.0, l = 10.0, pitch = 1.25, depth = 0.6) {
    eps = 0.05;
    major_r = d/2;
    minor_r = max(major_r - depth, eps);
    turns = l / pitch;

    union() {
        // Core cylinder (minor diameter)
        cylinder(h = l, r = minor_r);

        // Helical ridge (approximate external thread) limited to major diameter
        linear_extrude(height = l, twist = -360 * turns, slices = max(ceil(turns * 24), 24))
            translate([minor_r, 0, 0])
                circle(r = (major_r - minor_r));
    }
}

socket_head_cap_screw(shank_d=8.0, shank_l=10.0, head_d=16.0);