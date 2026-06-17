$fn = 128;

// Socket head cap screw
// Shank diameter: 4.0mm
// Head diameter: 8.0mm
// Length under head: 10.0mm

d_shank = 4.0;
L       = 10.0;

d_head  = 8.0;
h_head  = 4.0;

fillet_r = 0.35;

// Hex socket (internal recess)
hex_flat  = 3.0;   // across flats
hex_depth = 2.2;
hex_corner = hex_flat / cos(30); // across corners for hex prism

// Visible thread approximation
pitch        = 0.7;
thread_depth = 0.25;
thread_width = 0.35;
thread_clear = 0.15;

module thread_ridge(len, d_major, p, depth, w) {
    r = d_major/2 - depth/2;
    turns = len / p;
    linear_extrude(height=len, twist=turns*360, slices=max(ceil(turns*24), 24), convexity=10)
        translate([r, 0, 0])
            square([depth, w], center=true);
}

module screw() {
    eps = 0.05;
    overlap = 0.10; // ensures solids overlap (single connected solid)

    difference() {
        union() {
            // Head (z from 0 to h_head)
            cylinder(h=h_head, d=d_head);

            // Under-head fillet blend (overlaps both head and shank)
            hull() {
                translate([0,0,-overlap])
                    cylinder(h=eps, d=d_shank);
                translate([0,0,fillet_r])
                    cylinder(h=eps, d=d_shank + 2*fillet_r);
            }

            // Shank + threads (z from -L to 0), overlapping into head by 'overlap'
            translate([0,0,-L - overlap]) {
                // Core cylinder slightly under major diameter so ridge forms the "thread"
                cylinder(h=L + overlap, d=d_shank - 2*thread_depth);

                // Thread ridge, leaving a small unthreaded portion near the head for fillet
                thread_len = max(L - thread_clear, 0);
                if (thread_len > 0)
                    translate([0,0,0])
                        thread_ridge(thread_len, d_shank, pitch, thread_depth, thread_width);
            }
        }

        // Internal hex socket recess (kept clearly internal; does not create external hex)
        translate([0,0,h_head - hex_depth])
            cylinder(h=hex_depth + 0.2, d=hex_corner, $fn=6);
    }
}

screw();