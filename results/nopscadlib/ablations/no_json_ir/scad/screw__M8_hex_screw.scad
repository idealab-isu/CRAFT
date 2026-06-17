$fn = 96;

// Dimensions (mm)
shaft_d   = 8.0;
shaft_r   = shaft_d/2;
shaft_h   = 10.0;

head_d    = 15.0;          // across flats for hex head
head_h    = 5.65;

// Simple external thread look (kept subtle so it remains one solid)
thread_pitch = 1.25;
thread_depth = 0.35;       // radial increase over shaft radius
thread_start = 0.6;        // leave a small unthreaded lead-in
thread_end   = 0.6;        // leave a small unthreaded runout

module hex_head_screw() {
    union() {
        screw_shaft_with_threads();
        hex_head();
    }
}

module hex_head() {
    // Hex prism: cylinder with $fn=6 gives a true hex outline in orthographic views
    translate([0, 0, shaft_h])
        cylinder(h = head_h, d = head_d, $fn = 6);
}

module screw_shaft_with_threads() {
    union() {
        // Core shaft
        cylinder(h = shaft_h, d = shaft_d);

        // Thread ridge as a helical "wire" around the shaft (adds material, not subtracts)
        thread_len = shaft_h - thread_start - thread_end;
        if (thread_len > 0)
            translate([0, 0, thread_start])
                helical_thread_ridge(
                    r = shaft_r + thread_depth/2,
                    wire_d = thread_depth,
                    pitch = thread_pitch,
                    len = thread_len
                );
    }
}

module helical_thread_ridge(r, wire_d, pitch, len) {
    turns = len / pitch;
    // 360 deg per turn; use enough slices for smoothness
    slices = max(24, ceil(turns * 80));
    linear_extrude(height = len, twist = 360 * turns, slices = slices, convexity = 10)
        translate([r, 0, 0])
            circle(d = wire_d, $fn = 24);
}

hex_head_screw();