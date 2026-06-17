// Pan head screw: 6.0mm shank dia, 12.0mm head dia, 4.75mm head height, 10mm length under head
// One connected solid. No drive recess (request did not specify a drive type).

shaft_diameter     = 6.0;
length_under_head  = 10.0;
head_diameter      = 12.0;
head_height        = 4.75;

// Threads (visual approximation)
threaded       = 1;
thread_pitch   = 1.0;
thread_depth   = 0.35;   // radial height of thread ridge
thread_starts  = 1;
thread_length  = length_under_head;

// Quality
$fn = 120;

// Use a real overlap (1–2mm) to guarantee fusion between parts
overlap = 1.2;

module pan_head_solid(head_d, head_h, shank_d) {
    // Bottom of head at z=0, top at z=head_h.
    skirt_h = head_h * 0.55;
    dome_h  = head_h - skirt_h;

    union() {
        // Skirt
        translate([0, 0, skirt_h/2])
            cylinder(h=skirt_h, r=head_d/2, center=true);

        // Dome
        intersection() {
            translate([0, 0, skirt_h])
                scale([1, 1, dome_h/(head_d/2)])
                    sphere(r=head_d/2);
            translate([0, 0, skirt_h + dome_h/2])
                cylinder(h=dome_h + 2*overlap, r=head_d/2 + overlap, center=true);
        }

        // Under-head blend into shank
        cylinder(h=0.6, r1=shank_d/2, r2=head_d/2, center=false);
    }
}

module simple_thread_ridge(major_r, depth, pitch, length, starts=1) {
    turns = length / pitch;
    twist_deg = 360 * turns;

    for (s = [0:starts-1]) {
        rotate([0, 0, s * 360/starts])
            linear_extrude(
                height=length,
                twist=twist_deg,
                slices=max(30, ceil(turns*60)),
                convexity=10
            )
                polygon(points=[
                    [major_r - depth, -pitch*0.18],
                    [major_r,          0],
                    [major_r - depth,  pitch*0.18]
                ]);
    }
}

// A fused collar that guarantees the "ring/washer" and any nearby helix segments
// are physically attached to the main screw body (core + threads).
module fused_collar(minor_r, z_top, collar_h, overlap_amt) {
    // z_top is the collar's top plane. Collar extends downward.
    // Make it slightly larger than minor_r so it intersects both the core and the ridge.
    collar_r = minor_r + max(0.8, overlap_amt*0.6);

    translate([0, 0, z_top - collar_h - overlap_amt])
        cylinder(h=collar_h + 2*overlap_amt, r=collar_r, center=false);
}

module screw() {
    shank_r = shaft_diameter/2;
    minor_r = threaded ? (shank_r - thread_depth) : shank_r;

    // Coordinate system:
    // Under-head plane at z=0, tip at z=-length_under_head.

    // Thread ridge placement: ensure it overlaps the head/shank at the top and reaches past the tip.
    thread_z0 = -thread_length - overlap;          // bottom of ridge
    thread_len = thread_length + 2*overlap;        // extends to z=+overlap at top

    // Collar placement: directly under the head so it cannot float.
    // Top of collar is slightly inside the head/shank region to guarantee fusion.
    collar_h = 2.0;
    collar_top_z = 0 + overlap;                    // intersects shank/head by overlap

    difference() {
        union() {
            // Shank core: extend slightly into the head region to guarantee fusion
            translate([0, 0, (-length_under_head + overlap)/2])
                cylinder(h=length_under_head + overlap, r=minor_r, center=true);

            // Thread ridge: overlaps the core and reaches up to z=+overlap (into head/shank)
            if (threaded)
                translate([0, 0, thread_z0])
                    simple_thread_ridge(
                        major_r = shank_r,
                        depth   = thread_depth,
                        pitch   = thread_pitch,
                        length  = thread_len,
                        starts  = thread_starts
                    );

            // Fused collar: eliminates any disconnected thin ring and ties helix to the core
            if (threaded)
                fused_collar(
                    minor_r     = minor_r,
                    z_top       = collar_top_z,
                    collar_h    = collar_h,
                    overlap_amt = overlap
                );

            // Head: pushed down by overlap so it intersects the shank
            translate([0, 0, -overlap])
                pan_head_solid(head_diameter, head_height + overlap, shaft_diameter);
        }

        // Tip chamfer (subtractive)
        chamfer_h = 1.2;
        translate([0, 0, -length_under_head - overlap])
            cylinder(h=chamfer_h + 2*overlap, r1=0, r2=shank_r + overlap, center=false);
    }
}

screw();