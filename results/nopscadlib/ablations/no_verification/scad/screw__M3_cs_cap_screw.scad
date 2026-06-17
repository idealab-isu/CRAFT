// Socket head cap screw (M3-ish): 3.0mm shank dia, 6.0mm head dia, 10mm long
// One connected solid, with hex socket recess and visible (modeled) threads.

// Parameters
shaft_diameter_mm = 3.0; //[1.5:6.0:0.1]
head_diameter_mm  = 6.0; //[3.0:12.0:0.1]
length_mm         = 10.0; //[5.0:20.0:0.5]

head_height_mm    = 3.0; //[1.5:6.0:0.1]
socket_af_mm      = 2.5; //[1.5:4.0:0.1]
socket_depth_mm   = 1.6; //[0.8:3.0:0.1]

threaded_length_mm = 7.0; //[3.0:15.0:0.5]
thread_pitch_mm    = 0.5; //[0.35:1.2:0.05]   // coarse-ish for visibility
thread_depth_mm    = 0.18; //[0.05:0.35:0.01] // radial depth of thread
thread_starts      = 1;   //[1:4]             // keep 1 for typical screw

overlap_mm = 0.2; //[0.05:1.0:0.05]
$fn = 96;

// Derived
shaft_r = shaft_diameter_mm/2;
head_r  = head_diameter_mm/2;

shank_len = max(0, length_mm - head_height_mm);
thread_len = min(threaded_length_mm, shank_len);
plain_len  = max(0, shank_len - thread_len);

// Coordinate convention: z=0 at underside of head; head extends +z; shank extends -z.
module hex_prism_af(af, h, center=false) {
    // For a regular hexagon: across flats = 2 * apothem.
    // Circumradius R = apothem / cos(30) = (af/2)/cos(30)
    R = (af/2)/cos(30);
    cylinder(r=R, h=h, center=center, $fn=6);
}

module external_thread(r_major, pitch, len, depth, starts=1) {
    // Simple helical ridge (approximate ISO thread) using linear_extrude twist.
    // Creates a visible thread form without requiring libraries.
    turns = len / pitch;
    slices = max(ceil(turns * 40), 80);

    union() {
        // Base minor cylinder (keeps thread connected and printable)
        cylinder(r=max(r_major - depth, 0.01), h=len, center=false);

        // Helical ridge(s)
        for (s = [0:starts-1]) {
            rotate([0,0, s*360/starts])
                linear_extrude(height=len, twist=turns*360, slices=slices, center=false, convexity=10)
                    translate([r_major - depth/2, 0, 0])
                        // Narrow rectangular ridge; width ~ pitch/2 for visible helix
                        square([depth, pitch*0.55], center=true);
        }
    }
}

module socket_head_cap_screw() {
    difference() {
        union() {
            // Head: from z=0 to z=head_height_mm
            translate([0,0,0])
                cylinder(r=head_r, h=head_height_mm, center=false);

            // Plain shank (if any): from z=-plain_len to z=0
            if (plain_len > 0)
                translate([0,0,-plain_len])
                    cylinder(r=shaft_r, h=plain_len + overlap_mm, center=false);

            // Threaded portion: from z=-(plain_len+thread_len) to z=-plain_len
            if (thread_len > 0)
                translate([0,0,-(plain_len + thread_len)])
                    external_thread(
                        r_major=shaft_r,
                        pitch=thread_pitch_mm,
                        len=thread_len + overlap_mm,
                        depth=thread_depth_mm,
                        starts=thread_starts
                    );
        }

        // Hex socket recess in head (subtractive), from top down
        // Place so its top is flush with head top, with slight overlap.
        socket_h = min(socket_depth_mm, head_height_mm - 0.2);
        translate([0,0, head_height_mm - socket_h])
            hex_prism_af(socket_af_mm, socket_h + overlap_mm, center=false);
    }
}

socket_head_cap_screw();