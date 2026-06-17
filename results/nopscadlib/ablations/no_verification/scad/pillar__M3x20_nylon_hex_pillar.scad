// Standoff pillar, M3 external threads both ends, 20mm overall length.
// "Nonemm diameter" is undefined -> expose body_d_mm parameter for user to set.

$fn = 96;

// -------- Parameters --------
thread_major_d_mm = 3.0;     // M3 major diameter
length_mm         = 20.0;    // overall length
body_d_mm         = 6.0;     // standoff outer diameter (set as needed)

thread_len_top_mm    = 6.0;
thread_len_bottom_mm = 6.0;

chamfer_h_mm   = 0.8;
chamfer_drop_mm = 0.6;

// Visual thread parameters (not a standards-accurate ISO thread, but sized to M3 major dia)
thread_pitch_mm = 0.5;
thread_depth_mm = 0.25;

eps = 0.02;

// -------- Thread (visual) --------
module external_thread(major_d, pitch, depth, len) {
    major_r = major_d/2;
    minor_r = max(major_r - depth, 0.01);

    union() {
        // core at minor diameter
        cylinder(h=len, r=minor_r, center=true);

        // helical ridge up to major diameter
        linear_extrude(
            height=len,
            twist=360*len/pitch,
            slices=max(ceil(len*16), 32),
            convexity=10
        )
        translate([minor_r, 0, 0])
            polygon(points=[
                [0, -pitch*0.22],
                [major_r - minor_r, 0],
                [0,  pitch*0.22]
            ]);
    }
}

// -------- Standoff --------
module standoff() {
    body_r = body_d_mm/2;

    // Clamp thread lengths to fit within total length
    tbot = min(thread_len_bottom_mm, length_mm/2);
    ttop = min(thread_len_top_mm,    length_mm/2);

    // Ensure body is at least as large as thread major diameter
    body_r_eff = max(body_r, thread_major_d_mm/2);

    cham_h = min(chamfer_h_mm, length_mm/2);
    cham_r2 = max(body_r_eff - chamfer_drop_mm, 0.01);

    overlap = 0.3; // guarantees one connected solid

    union() {
        // Main body
        cylinder(h=length_mm, r=body_r_eff, center=true);

        // Bottom thread (connected via overlap)
        translate([0, 0, -length_mm/2 + tbot/2 + overlap/2])
            external_thread(thread_major_d_mm, thread_pitch_mm, thread_depth_mm, tbot + overlap);

        // Top thread (connected via overlap)
        translate([0, 0,  length_mm/2 - ttop/2 - overlap/2])
            external_thread(thread_major_d_mm, thread_pitch_mm, thread_depth_mm, ttop + overlap);

        // Bottom chamfer
        translate([0, 0, -length_mm/2 + cham_h/2 + eps])
            cylinder(h=cham_h + eps, r1=body_r_eff, r2=cham_r2, center=true);

        // Top chamfer
        translate([0, 0,  length_mm/2 - cham_h/2 - eps])
            cylinder(h=cham_h + eps, r1=cham_r2, r2=body_r_eff, center=true);
    }
}

standoff();