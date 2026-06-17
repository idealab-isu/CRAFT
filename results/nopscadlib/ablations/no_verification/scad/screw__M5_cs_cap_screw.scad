// Socket head cap screw: 5.0mm shank dia, 10.0mm head dia, 10.0mm overall length
// One connected solid, with visible hex socket recess and simplified external threads.

$fn = 128;

// Parameters (fixed to requested)
shaft_diameter_mm = 5.0;
head_diameter_mm  = 10.0;
length_mm         = 10.0;   // overall length (under head + head)
head_height_mm    = 5.0;

hex_socket_across_flats_mm = 4.0;
hex_socket_depth_mm        = 3.0;

thread_pitch_mm  = 0.8;
thread_depth_mm  = 0.35;
thread_length_mm = 5.0;    // typical for a 10mm long SHCS; clamped to under-head length

chamfers = 1;
head_top_chamfer_mm = 0.6;
tip_chamfer_mm      = 0.8;

overlap_mm = 0.25;

// Helpers
function clamp(x, a, b) = min(max(x, a), b);

module hex_prism_af(af, h) {
    // across flats -> circumradius
    r = af/(2*cos(30));
    cylinder(h=h, r=r, $fn=6, center=false);
}

module external_thread(d_major, pitch, depth, len) {
    // Robust simplified thread: helical extrusion of a small triangular "tooth"
    // extruded around the Z axis. Union with a minor-diameter core.
    turns = len / pitch;
    r_major = d_major/2;
    r_minor = r_major - depth;

    // Tooth profile in XY, centered near +X; then rotate_extrude with twist.
    // Keep slightly inside major radius to avoid self-intersections.
    eps = 0.03;
    tooth = [
        [r_minor, -pitch*0.22],
        [r_major - eps, 0],
        [r_minor,  pitch*0.22]
    ];

    linear_extrude(height=len, twist=turns*360, slices=max(ceil(turns*40), 60), convexity=10)
        polygon(points=tooth);
}

module socket_head_cap_screw() {
    head_h = head_height_mm;
    shank_d = shaft_diameter_mm;
    head_d = head_diameter_mm;

    // Under-head length
    under_head_len = max(length_mm - head_h, 0.01);

    // Thread depth clamp
    depth = clamp(thread_depth_mm, 0, shank_d/2 - 0.25);
    d_minor = max(shank_d - 2*depth, 0.5);

    // Thread length clamp
    t_len = clamp(thread_length_mm, 0, under_head_len);

    // Socket depth clamp (ensure visible recess and leave bottom thickness)
    socket_depth = clamp(hex_socket_depth_mm, 0.5, head_h - 0.6);

    difference() {
        union() {
            // Shaft core (minor diameter) - full under-head length
            cylinder(h=under_head_len + overlap_mm, d=d_minor, center=false);

            // External thread (starts at tip, runs upward)
            if (t_len > 0.01)
                external_thread(d_major=shank_d, pitch=thread_pitch_mm, depth=depth, len=t_len);

            // Tip chamfer (connected)
            if (chamfers && tip_chamfer_mm > 0) {
                cham_h = min(tip_chamfer_mm, under_head_len);
                cylinder(h=cham_h, r1=shank_d/2, r2=max(shank_d/2 - cham_h, 0.2), center=false);
            }

            // Head (connected at z = under_head_len)
            translate([0,0,under_head_len - overlap_mm])
                cylinder(h=head_h + overlap_mm, d=head_d, center=false);

            // Head top chamfer (connected)
            if (chamfers && head_top_chamfer_mm > 0) {
                ch = min(head_top_chamfer_mm, head_h*0.8);
                translate([0,0,under_head_len + head_h - ch])
                    cylinder(h=ch + overlap_mm, r1=head_d/2, r2=max(head_d/2 - ch, 0.2), center=false);
            }
        }

        // Hex socket recess (subtracted from head, from top down)
        translate([0,0,under_head_len + head_h - socket_depth])
            hex_prism_af(hex_socket_across_flats_mm, socket_depth + overlap_mm);

        // Small lead-in chamfer for socket opening to make it clearly visible
        translate([0,0,under_head_len + head_h - 0.6])
            cylinder(h=0.6 + overlap_mm,
                     r1=(hex_socket_across_flats_mm/(2*cos(30))) + 0.25,
                     r2=(hex_socket_across_flats_mm/(2*cos(30))),
                     $fn=6, center=false);
    }
}

socket_head_cap_screw();