$fn = 128;

// Requested dimensions
shaft_d   = 8.0;     // major diameter (thread OD)
shaft_len = 10.0;    // length under head

head_d    = 15.0;    // head diameter across corners (circumscribed)
head_h    = 5.65;    // head height

// Simple external thread parameters (visual thread; not a standard)
pitch     = 1.25;    // mm
thread_depth = 0.65; // radial depth (mm)
tip_flat_h   = 0.6;  // small unthreaded flat at tip

eps = 0.02;

module hex_prism_across_corners(d, h) {
    R = d/2; // circumradius
    linear_extrude(height = h)
        polygon(points = [for (i = [0:5]) [R*cos(60*i), R*sin(60*i)]]);
}

// Helical thread as a twisted extrusion of a triangular profile
module external_thread(major_d, length, pitch, depth) {
    major_r = major_d/2;
    minor_r = major_r - depth;

    // Keep minor radius positive
    minor_r2 = max(minor_r, 0.1);

    turns = length / pitch;
    twist_deg = 360 * turns;

    // Triangular profile in (radius, z) plane, extruded around Z with twist
    // Profile spans one pitch in Z and goes from minor_r2 to major_r.
    linear_extrude(height = length, twist = twist_deg, slices = max(ceil(turns*40), 60), convexity = 10)
        polygon(points = [
            [minor_r2, 0],
            [major_r,  pitch/2],
            [minor_r2, pitch]
        ]);
}

union() {
    // Threaded shank (from z=0 to z=shaft_len)
    // Add a tiny overlap into the head for watertight union.
    external_thread(shaft_d, shaft_len + eps, pitch, thread_depth);

    // Small flat at the tip to avoid a razor edge
    cylinder(d = shaft_d - 2*thread_depth, h = tip_flat_h);

    // Hex head on top of shank (connected with slight overlap)
    translate([0, 0, shaft_len - eps])
        hex_prism_across_corners(head_d, head_h + eps);
}