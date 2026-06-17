$fn = 96;

module socket_head_cap_screw(
    shank_d = 5.0,
    length  = 10.0,   // under-head length
    head_d  = 8.5,
    head_h  = 5.0,
    socket_af = 4.0,  // hex across-flats (typical for ~M5)
    socket_depth = 3.0,
    thread_pitch = 0.8,
    thread_depth = 0.35
) {
    eps = 0.02;

    union() {
        // Main solid (head + threaded shank)
        difference() {
            union() {
                // Shank with external thread approximation
                threaded_shank(d=shank_d, h=length, pitch=thread_pitch, depth=thread_depth);

                // Head sits on top of shank (connected by construction)
                translate([0, 0, length])
                    cylinder(d=head_d, h=head_h, center=false);
            }

            // Hex socket recess cut into head from the top
            translate([0, 0, length + head_h - socket_depth])
                cylinder(h=socket_depth + eps, d=socket_af / cos(30), $fn=6, center=false);

            // Small lead-in chamfer for socket
            translate([0, 0, length + head_h - socket_depth - 0.6])
                cylinder(h=0.6 + eps, d1=(socket_af / cos(30)) * 1.08, d2=(socket_af / cos(30)), $fn=6, center=false);
        }
    }
}

module threaded_shank(d=5.0, h=10.0, pitch=0.8, depth=0.35) {
    // Simple external thread approximation using a helical triangular ridge
    // Ensures a single connected solid with visible threads.
    r = d/2;
    turns = h / pitch;

    union() {
        // Core cylinder slightly under major diameter so the ridge is visible
        cylinder(r=r - depth*0.55, h=h, center=false);

        // Helical ridge
        linear_extrude(height=h, twist=turns*360, slices=max(ceil(turns*24), 60), center=false, convexity=10)
            translate([r - depth*0.55, 0, 0])
                polygon(points=[
                    [0, -pitch*0.22],
                    [depth, 0],
                    [0,  pitch*0.22]
                ]);
    }
}

socket_head_cap_screw();