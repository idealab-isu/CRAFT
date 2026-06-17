// Socket head cap screw: 6.0mm shank dia, 12.0mm head dia, 10mm long (under head)
// Includes visible hex socket and simplified external threads.
// One connected solid (no washer).

$fn = 120;

// --- Target dimensions ---
shank_diameter_mm = 6.0;
length_mm         = 10.0;   // under-head length
head_diameter_mm  = 12.0;
head_height_mm    = 6.0;

// Hex socket (approx for M6 SHCS)
socket_af_mm      = 5.0;    // across flats
socket_depth_mm   = 3.0;

// Simplified thread geometry (visual, not ISO-accurate)
thread_pitch_mm   = 1.0;
thread_depth_mm   = 0.55;   // radial depth
thread_start_mm   = 0.6;    // unthreaded near head
thread_end_mm     = 0.4;    // unthreaded at tip

overlap_mm        = 0.25;

// --- Helpers ---
function hex_R_from_AF(af) = af / sqrt(3); // circumradius for hex with given across-flats

module hex_prism(af, h, center=false) {
    cylinder(h=h, r=hex_R_from_AF(af), $fn=6, center=center);
}

module external_thread(d_major, pitch, depth, len) {
    // Helical ridge unioned with a root cylinder.
    turns   = len / pitch;
    r_major = d_major/2;
    r_root  = r_major - depth;

    union() {
        // Root cylinder
        cylinder(h=len, r=r_root, center=false);

        // Helical ridge
        linear_extrude(height=len, twist=turns*360,
                       slices=max(ceil(turns*28), 28),
                       center=false, convexity=10)
            translate([r_root, 0, 0])
                polygon(points=[
                    [0, -pitch*0.22],
                    [depth, 0],
                    [0,  pitch*0.22]
                ]);
    }
}

module socket_head_cap_screw() {
    // Coordinate system:
    // underside of head at z=0
    // head spans z=[0, head_height]
    // shank spans z=[-length, 0]

    union() {
        // Head with hex socket recess
        difference() {
            translate([0,0, head_height_mm/2])
                cylinder(h=head_height_mm, r=head_diameter_mm/2, center=true);

            // Hex socket cut from top face downward
            translate([0,0, head_height_mm - socket_depth_mm/2 + overlap_mm/2])
                hex_prism(socket_af_mm, socket_depth_mm + overlap_mm, center=true);
        }

        // Shank (unthreaded + threaded + unthreaded), positioned to connect to head
        thread_len = max(0, length_mm - thread_start_mm - thread_end_mm);

        // Place shank so its top slightly overlaps into the head underside at z=0
        translate([0,0, -length_mm + overlap_mm])
        union() {
            // Tip unthreaded section at bottom
            cylinder(h=thread_end_mm + overlap_mm, r=shank_diameter_mm/2, center=false);

            // Threaded section above tip
            translate([0,0, thread_end_mm])
                external_thread(shank_diameter_mm, thread_pitch_mm, thread_depth_mm, thread_len);

            // Unthreaded near head at top
            translate([0,0, thread_end_mm + thread_len])
                cylinder(h=thread_start_mm + overlap_mm, r=shank_diameter_mm/2, center=false);
        }
    }
}

socket_head_cap_screw();