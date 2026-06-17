// Socket head cap screw (one connected solid)
// Requested: 8.0mm shank diameter, 16.0mm head diameter, 10mm long (under-head length)

shaft_diameter_mm = 8;   //[4:16:0.1]
head_diameter_mm  = 16;  //[8:32:0.1]
length_mm         = 10;  //[5:40:0.1]   // under-head length
head_height_mm    = 8;   //[4:20:0.1]

hex_socket_across_flats_mm = 6; //[3:12:0.1]
hex_socket_depth_mm        = 4; //[2:12:0.1]

end_chamfer_height_mm = 1;   //[0.5:3:0.1]
top_edge_chamfer_mm   = 0.6; //[0:2:0.1]

thread_pitch_mm   = 1.25; //[0.5:3:0.05]
thread_depth_mm   = 0.6;  //[0.2:1.2:0.05]
thread_start_mm   = 0.8;  //[0:3:0.1]   // unthreaded length under head

overlap_mm = 0.25; //[0.05:1:0.05]

$fn = 128;

// Helpers
function hex_circumradius_from_flats(af) = (af/2)/cos(30);

module helical_thread_approx(major_r, pitch, depth, len, starts=1) {
    // Simple external thread approximation using a helical triangular ridge.
    // Not standards-accurate, but clearly threaded and printable.
    turns = len / pitch;
    slices_per_turn = 24;
    steps = max(12, ceil(turns * slices_per_turn));
    twist_deg = 360 * turns;

    // 2D profile in X-Y, extruded along Z with twist.
    // Profile is a small triangle near the major radius.
    linear_extrude(height=len, twist=twist_deg, slices=steps, convexity=10)
        polygon(points=[
            [major_r - depth, -pitch*0.22],
            [major_r,          0],
            [major_r - depth,  pitch*0.22]
        ]);
}

module socket_head_cap_screw() {
    sh_r = shaft_diameter_mm/2;
    hd_r = head_diameter_mm/2;

    // z=0 at underside of head (bearing surface)
    // shank extends to z = -length_mm
    // head extends to z = +head_height_mm
    difference() {
        union() {
            // Head: bottom at z=0, top at z=head_height_mm
            // Use a main cylinder plus a small top chamfer frustum.
            union() {
                // Main head body (up to start of chamfer)
                translate([0,0,(head_height_mm - top_edge_chamfer_mm)/2])
                    cylinder(r=hd_r, h=max(0.01, head_height_mm - top_edge_chamfer_mm), center=true);

                // Top chamfer
                translate([0,0,head_height_mm - top_edge_chamfer_mm/2])
                    cylinder(r1=hd_r, r2=max(0.01, hd_r - top_edge_chamfer_mm),
                             h=top_edge_chamfer_mm + overlap_mm, center=true);
            }

            // Shank core (minor diameter so thread ridge builds to major diameter)
            minor_r = max(0.01, sh_r - thread_depth_mm);
            translate([0,0,-length_mm/2])
                cylinder(r=minor_r, h=length_mm + overlap_mm, center=true);

            // Thread ridge (starts after an unthreaded section under head)
            thread_len = max(0, length_mm - thread_start_mm);
            if (thread_len > 0.01) {
                translate([0,0,-thread_start_mm - thread_len])
                    helical_thread_approx(major_r=sh_r, pitch=thread_pitch_mm, depth=thread_depth_mm, len=thread_len);
            }

            // End chamfer (conical tip) connected to shank
            translate([0,0,-length_mm + end_chamfer_height_mm/2])
                cylinder(r1=sh_r, r2=max(0.01, sh_r - end_chamfer_height_mm),
                         h=end_chamfer_height_mm + overlap_mm, center=true);
        }

        // Hex socket cut from top down
        translate([0,0,head_height_mm - hex_socket_depth_mm/2])
            cylinder(r=hex_circumradius_from_flats(hex_socket_across_flats_mm),
                     h=hex_socket_depth_mm + overlap_mm, center=true, $fn=6);

        // Lead-in at socket mouth
        translate([0,0,head_height_mm - top_edge_chamfer_mm/2])
            cylinder(r1=hex_circumradius_from_flats(hex_socket_across_flats_mm) + 0.5,
                     r2=hex_circumradius_from_flats(hex_socket_across_flats_mm),
                     h=top_edge_chamfer_mm + overlap_mm, center=true, $fn=6);
    }
}

socket_head_cap_screw();