$fn = 96;

// Dimensions (mm)
shaft_diameter       = 3.0;     // major diameter
overall_length       = 10.0;    // under-head to tip + head height
head_across_flats    = 6.4;     // hex across flats
head_height          = 2.125;

thread_pitch         = 0.5;     // visual thread pitch (approx for M3)
thread_depth         = 0.18;    // radial depth of thread (visual)
thread_starts        = 1;

overlap = 0.05; // small overlap to guarantee a single connected solid

thread_length = overall_length - head_height;

// Hex head (across flats = head_across_flats)
module hex_head(af, h) {
    // For a regular hex: across flats = sqrt(3) * R  => R = af / sqrt(3)
    R = af / sqrt(3);
    cylinder(h = h, r = R, $fn = 6);
}

// Simple helical thread ridge wrapped around a core cylinder
module threaded_shank(d_major, len, pitch, depth, starts=1) {
    r_major = d_major/2;
    r_core  = max(0.01, r_major - depth);

    union() {
        // Core
        cylinder(h = len, r = r_core);

        // Helical ridge(s)
        for (s = [0:starts-1]) {
            rotate([0, 0, s*360/starts])
                linear_extrude(height = len, twist = 360*len/pitch, slices = max(20, ceil(len*24)), convexity = 10)
                    translate([r_core, 0, 0])
                        circle(r = depth, $fn = 24);
        }
    }
}

module screw() {
    union() {
        // Threaded shank from z=0 to z=thread_length
        threaded_shank(shaft_diameter, thread_length, thread_pitch, thread_depth, thread_starts);

        // Hex head on top, connected with overlap
        translate([0, 0, thread_length - overlap])
            hex_head(head_across_flats, head_height + overlap);
    }
}

screw();