$fn = 128;

// Socket head cap screw (approximate) with visible threads and a pointed tip.
// Dimensions requested:
// - Shank diameter: 8.0 mm
// - Head diameter: 13.0 mm
// - Head height: 8.0 mm
// - Length under head: 10.0 mm

module socket_head_cap_screw(
    shaft_diameter     = 8.0,
    head_diameter      = 13.0,
    head_height        = 8.0,
    length_under_head  = 10.0,

    // Typical M8 internal hex is 6 mm AF
    hex_af             = 6.0,
    hex_depth          = 5.0,

    // Thread look (cosmetic)
    thread_pitch       = 1.25,
    thread_depth       = 0.35,   // radial depth (cosmetic)
    thread_start_z     = 0.8,    // unthreaded length under head
    tip_length         = 1.2,    // pointed tip length

    // Small edge breaks
    head_top_chamfer   = 0.6,
    head_bottom_chamfer= 0.4,

    overlap            = 0.05
) {
    shaft_r = shaft_diameter/2;
    head_r  = head_diameter/2;

    // Clamp features to stay valid
    tip_len   = min(tip_length, max(length_under_head - 0.2, 0));
    thread_z0 = min(max(thread_start_z, 0), max(length_under_head - tip_len, 0));
    thread_len= max(length_under_head - tip_len - thread_z0, 0);

    hex_depth_final = min(max(hex_depth, 0.1), max(head_height - 0.8, 0.1));

    difference() {
        union() {
            // HEAD (z: 0 .. head_height)
            union() {
                cylinder(h=head_height, r=head_r, center=false);

                // Top chamfer
                if (head_top_chamfer > 0)
                    translate([0,0,head_height - head_top_chamfer])
                        cylinder(h=head_top_chamfer + overlap,
                                 r1=head_r,
                                 r2=max(head_r - head_top_chamfer, 0.01),
                                 center=false);

                // Bottom chamfer/transition to shank
                if (head_bottom_chamfer > 0)
                    translate([0,0,0])
                        cylinder(h=head_bottom_chamfer + overlap,
                                 r1=max(shaft_r, 0.01),
                                 r2=head_r,
                                 center=false);
            }

            // SHANK CORE (z: -length_under_head .. 0)
            translate([0,0,-length_under_head])
                cylinder(h=length_under_head + overlap, r=shaft_r, center=false);

            // COSMETIC THREADS (helical ridge) on the shank
            if (thread_len > 0 && thread_depth > 0) {
                translate([0,0,-length_under_head + thread_z0])
                    thread_ridge(
                        major_r = shaft_r,
                        depth   = thread_depth,
                        pitch   = thread_pitch,
                        length  = thread_len
                    );
            }

            // POINTED TIP (z: -length_under_head .. -length_under_head+tip_len)
            if (tip_len > 0)
                translate([0,0,-length_under_head])
                    cylinder(h=tip_len, r1=max(shaft_r - 0.6, 0.01), r2=shaft_r, center=false);
        }

        // INTERNAL HEX SOCKET (recessed from top)
        translate([0,0,head_height - hex_depth_final])
            hex_socket(af=hex_af, depth=hex_depth_final + overlap);

        // Small lead-in at socket mouth (subtle countersink)
        translate([0,0,head_height - 0.6])
            cylinder(h=0.6 + overlap,
                     r1=(hex_af/sqrt(3)) * 1.05,
                     r2=(hex_af/sqrt(3)) * 0.98,
                     center=false);
    }
}

// Regular hex prism: across flats = af
module hex_socket(af, depth) {
    r = af / sqrt(3); // circumradius
    linear_extrude(height=depth, center=false, convexity=10)
        polygon(points=[for(i=[0:5]) [r*cos(60*i), r*sin(60*i)]]);
}

// Cosmetic external thread ridge (adds material) using linear_extrude with twist.
// This is not a standards-accurate thread profile, but reads clearly as "threaded".
module thread_ridge(major_r, depth, pitch, length) {
    turns = length / pitch;
    // A small triangular ridge placed at the major radius
    linear_extrude(height=length, twist=turns*360, center=false, convexity=10)
        translate([major_r - depth, 0, 0])
            polygon(points=[
                [0, -pitch*0.18],
                [depth, 0],
                [0,  pitch*0.18]
            ]);
}

socket_head_cap_screw();