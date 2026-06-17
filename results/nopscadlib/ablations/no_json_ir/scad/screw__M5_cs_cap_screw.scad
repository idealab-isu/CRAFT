$fn = 96;

module socket_head_cap_screw(
    shank_d = 5.0,        // shank major diameter
    head_d  = 10.0,       // head diameter
    length  = 10.0,       // overall length (under head to tip + head height)
    head_h  = 5.0,        // head height
    socket_af = 4.0,      // internal hex across-flats (approx for M5)
    socket_depth = 3.0,   // recess depth
    thread_pitch = 0.8,
    thread_depth = 0.35
) {
    eps = 0.02;

    shank_r = shank_d/2;
    head_r  = head_d/2;

    // Enforce overall length exactly = length
    head_h_eff = min(head_h, length);
    shank_h    = max(0, length - head_h_eff);

    // Hex socket: across-flats -> circumscribed diameter for $fn=6 cylinder
    socket_circ_d = socket_af / cos(30);

    // Thread approximation (helical ridge) on shank only
    thread_h = shank_h;
    turns = (thread_pitch > 0) ? (thread_h / thread_pitch) : 0;

    // Keep core radius positive
    core_r = max(0.01, shank_r - thread_depth);

    difference() {
        union() {
            // Shank core (under head)
            if (shank_h > 0)
                cylinder(h=shank_h, r=core_r, center=false);

            // Thread ridge (approx) fused to core
            if (thread_h > 0 && turns > 0 && thread_depth > 0)
                linear_extrude(height=thread_h, twist=turns*360, slices=max(24, ceil(turns*32)))
                    translate([core_r + thread_depth/2, 0, 0])
                        circle(r=thread_depth/2, $fn=24);

            // Cylindrical socket head, connected to shank (slight overlap)
            translate([0, 0, shank_h - eps])
                cylinder(h=head_h_eff + eps, r=head_r, center=false);
        }

        // Internal hex socket recess from top face of head
        socket_depth_eff = min(socket_depth, max(0, head_h_eff - 0.5));
        if (socket_depth_eff > 0)
            translate([0, 0, shank_h + head_h_eff - socket_depth_eff])
                cylinder(h=socket_depth_eff + eps, d=socket_circ_d, $fn=6, center=false);
    }
}

socket_head_cap_screw(shank_d=5.0, head_d=10.0, length=10.0);