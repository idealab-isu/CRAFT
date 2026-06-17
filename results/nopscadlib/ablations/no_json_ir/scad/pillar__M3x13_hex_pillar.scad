$fn = 120;

// External thread approximation (kept as-is, but made robust for unioning)
module external_thread(d_major=3.0, pitch=0.5, length=6.0, thread_depth=0.18) {
    turns  = length / pitch;
    d_core = d_major - 2*thread_depth;

    union() {
        // Core
        cylinder(h=length, d=d_core, center=false);

        // Helical ridge
        linear_extrude(
            height=length,
            twist=turns*360,
            slices=max(12, ceil(turns*40)),
            convexity=10
        )
            translate([d_core/2, 0, 0])
                circle(r=thread_depth);
    }
}

module standoff_pillar_M3(total_len=13.0, body_af=5.5, thread_len=4.0, overlap=1.2) {
    // Body length derived from total length
    body_len = total_len - 2*thread_len;

    // Hex cylinder diameter from across-flats
    body_d = body_af / cos(30);

    // Place everything along +Z (then rotate at end if desired)
    // Ensure BOTH thread-to-body interfaces overlap by 'overlap' (1–2mm).
    union() {
        // Lower thread (0 .. thread_len)
        external_thread(d_major=3.0, pitch=0.5, length=thread_len, thread_depth=0.18);

        // Body overlaps into lower thread by 'overlap' and into upper thread by 'overlap'
        // Body spans: (thread_len - overlap) .. (thread_len + body_len + overlap)
        translate([0, 0, thread_len - overlap])
            cylinder(h=body_len + 2*overlap, d=body_d, $fn=6, center=false);

        // Upper thread starts slightly inside the body to guarantee connection
        // Upper thread spans: (thread_len + body_len - overlap) .. (thread_len + body_len - overlap + thread_len)
        translate([0, 0, thread_len + body_len - overlap])
            external_thread(d_major=3.0, pitch=0.5, length=thread_len, thread_depth=0.18);
    }
}

// Orient along X so orthographic views show length
rotate([0, 90, 0])
    standoff_pillar_M3(total_len=13.0, body_af=5.5, thread_len=4.0, overlap=1.2);