$fn = 128;

// Target dimensions (mm)
shaft_d = 5.0;
shaft_r = shaft_d/2;

head_d = 9.2;          // across flats
head_h = 3.65;

length_under_head = 10.0;   // shank length under head

// Simple external thread approximation (visual)
thread_pitch = 0.8;          // mm (approx for M5)
thread_depth = 0.35;         // mm radial (visual)
thread_starts = 1;
thread_turns = length_under_head / thread_pitch;

// Derived: hex circumradius from across-flats
head_R = head_d / sqrt(3);

// Small overlap to guarantee watertight union
eps = 0.05;

module hex_prism(h, across_flats) {
    R = across_flats / sqrt(3);
    cylinder(h=h, r=R, $fn=6);
}

module threaded_shank(len, r_core, pitch, depth, starts=1) {
    union() {
        // Core cylinder
        cylinder(h=len, r=r_core);

        // Helical ridge (approx thread)
        for (s = [0:starts-1]) {
            rotate([0,0, s*360/starts])
                linear_extrude(height=len, twist=360*(len/pitch), slices=max(ceil(len*8), 80))
                    translate([r_core - depth/2, 0, 0])
                        circle(r=depth/2, $fn=24);
        }
    }
}

module hex_head_screw() {
    union() {
        // Head: z from 0..head_h
        hex_prism(head_h, head_d);

        // Shank + threads: z from -length_under_head..0, overlapped into head by eps
        translate([0,0,-length_under_head - eps])
            threaded_shank(length_under_head + eps, shaft_r, thread_pitch, thread_depth, thread_starts);
    }
}

hex_head_screw();