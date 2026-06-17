// Dome head screw (M5) - 5.0mm major dia, 9.5mm head dia, 2.75mm head height, 10mm long
// One connected solid. Underside of head at z=0, screw extends to negative z.

shaft_diameter_mm = 5.0;     // major diameter (thread OD)
length_mm         = 10.0;    // from underside of head to tip

head_diameter_mm  = 9.5;
head_height_mm    = 2.75;

// Internal hex socket (typical dome/button head). Set depth to 0 to disable.
hex_socket_af_mm     = 4.0;
hex_socket_depth_mm  = 2.0;

// Thread appearance controls (simple helical ridge; not a standards-accurate ISO profile)
thread_pitch_mm   = 0.8;     // M5 coarse pitch
thread_depth_mm   = 0.35;    // radial height of ridge (visual)
thread_start_mm   = 0.6;     // unthreaded length under head
thread_end_mm     = 0.6;     // unthreaded at tip

// Connectivity overlap (1-2mm as required)
overlap_mm = 1.2;
$fn = 120;

module helical_thread_ridge(d_major=5, pitch=0.8, depth=0.35, len=8, slices_per_turn=28) {
    r_major = d_major/2;
    turns = len / pitch;
    steps = max(12, ceil(turns * slices_per_turn));
    twist_deg = 360 * turns;

    // Ridge is built around the shaft radius; must be placed so its Z-range overlaps the shaft.
    linear_extrude(height=len, twist=twist_deg, slices=steps, convexity=10)
        translate([r_major - depth, 0, 0])
            polygon(points=[
                [0, -pitch*0.22],
                [depth, 0],
                [0,  pitch*0.22]
            ]);
}

module dome_head(d_head=9.5, h_head=2.75) {
    r_head = d_head/2;

    // Spherical cap trimmed to exact height: base at z=0, top at z=h_head
    intersection() {
        translate([0,0,h_head - r_head])
            sphere(r=r_head);
        translate([0,0,h_head/2])
            cube([d_head*2.2, d_head*2.2, h_head], center=true);
    }
}

module dome_head_screw(
    d_shaft=5.0,
    L=10.0,
    d_head=9.5,
    h_head=2.75,
    af_hex=4.0,
    depth_hex=2.0,
    pitch=0.8,
    thread_depth=0.35,
    thread_start=0.6,
    thread_end=0.6
){
    // Threaded length (kept within shaft length)
    thread_len = max(0, L - thread_start - thread_end);

    // Core shaft (minor diameter approximation so ridge reaches major diameter)
    d_core = max(0.1, d_shaft - 2*thread_depth);

    difference() {
        union() {
            // Core cylinder: overlaps into head by overlap_mm to guarantee attachment
            // Bottom at z=-L, top at z=+overlap_mm
            translate([0,0,(-L + overlap_mm)/2])
                cylinder(d=d_core, h=L + overlap_mm, center=true);

            // Helical ridge (threads): FIXED Z PLACEMENT so it is NOT floating.
            // Place ridge so its Z-range overlaps the shaft and stays on the shank:
            // Ridge spans from z = -(thread_start + overlap_mm) down to z = -(L - thread_end - overlap_mm)
            // (i.e., it starts just under the head and ends just above the tip), ensuring 1-2mm overlap at both ends.
            if (thread_len > 0) {
                thread_top_z    = -(thread_start + overlap_mm);                 // near head (slightly into unthreaded zone)
                thread_bottom_z = -(L - thread_end - overlap_mm);               // near tip (slightly into unthreaded zone)
                thread_h        = max(0.01, thread_top_z - thread_bottom_z);    // positive height

                translate([0,0,thread_bottom_z])
                    helical_thread_ridge(
                        d_major=d_shaft,
                        pitch=pitch,
                        depth=thread_depth,
                        len=thread_h,
                        slices_per_turn=30
                    );
            }

            // Tip chamfer (simple cone) to avoid flat-ended pin look; stays within length
            tip_h = min(1.0, L*0.25);
            translate([0,0,-L + tip_h/2])
                cylinder(
                    h=tip_h,
                    d1=d_core,
                    d2=max(0.1, d_core*0.6),
                    center=true
                );

            // Dome head: base at z=0
            dome_head(d_head=d_head, h_head=h_head);

            // Under-head collar/fillet: spans across z=0 so it intersects BOTH head and shaft by ~overlap_mm
            // Bottom at z=-overlap_mm, top at z=+overlap_mm
            translate([0,0,0])
                cylinder(d1=d_shaft, d2=d_shaft + 0.8, h=2*overlap_mm, center=true);
        }

        // Internal hex socket cut (not external hex)
        if (depth_hex > 0) {
            d_hex = af_hex / cos(30); // across-flats to circumscribed diameter
            socket_depth = min(depth_hex, h_head - 0.2);
            // Keep socket fully within head height; add overlap for clean subtraction
            translate([0,0,h_head - socket_depth/2 + overlap_mm/2])
                cylinder(d=d_hex, h=socket_depth + overlap_mm, center=true, $fn=6);
        }
    }
}

dome_head_screw(
    d_shaft=shaft_diameter_mm,
    L=length_mm,
    d_head=head_diameter_mm,
    h_head=head_height_mm,
    af_hex=hex_socket_af_mm,
    depth_hex=hex_socket_depth_mm,
    pitch=thread_pitch_mm,
    thread_depth=thread_depth_mm,
    thread_start=thread_start_mm,
    thread_end=thread_end_mm
);