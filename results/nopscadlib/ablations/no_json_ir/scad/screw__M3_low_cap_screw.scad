$fn = 96;

// Simple helical thread approximation (triangular profile) for visual threads
module approx_threaded_rod(d=3.0, h=10.0, pitch=0.5, depth=0.18, overlap=0.05) {
    turns = h / pitch;
    // 2D triangular "tooth" placed at the rod radius, then helically extruded
    linear_extrude(height = h + overlap, twist = 360 * turns, slices = max(ceil(turns * 24), 24), center = false)
        translate([d/2 - depth, 0])
            polygon(points=[
                [0, -pitch*0.22],
                [depth, 0],
                [0,  pitch*0.22]
            ]);
}

module metric_socket_head_cap_screw(
    shank_d = 3.0,
    length  = 10.0,   // under-head length
    head_d  = 5.5,
    head_h  = 2.0,
    socket_af = 2.5,      // across flats (approx for M3)
    socket_depth = 1.5,   // recess depth
    pitch = 0.5,          // coarse visual pitch for M3
    thread_depth = 0.18,  // visual thread depth
    overlap = 0.05
) {
    socket_depth_eff = min(socket_depth, head_h - 0.2);

    difference() {
        // ONE connected solid: threaded shank + head
        union() {
            // Base shank cylinder (minor diameter approximation)
            cylinder(h = length, d = shank_d - 2*thread_depth, center = false);

            // Add helical thread ridges (unioned, not floating)
            approx_threaded_rod(d = shank_d, h = length, pitch = pitch, depth = thread_depth, overlap = overlap);

            // Head, connected to shank with slight overlap
            translate([0, 0, length - overlap])
                cylinder(h = head_h + overlap, d = head_d, center = false);
        }

        // Internal hex socket recess (subtracted from head)
        translate([0, 0, length + head_h - socket_depth_eff])
            cylinder(
                h = socket_depth_eff + overlap,
                d = socket_af / cos(30),
                $fn = 6,
                center = false
            );
    }
}

metric_socket_head_cap_screw(shank_d=3.0, length=10.0, head_d=5.5, head_h=2.0);