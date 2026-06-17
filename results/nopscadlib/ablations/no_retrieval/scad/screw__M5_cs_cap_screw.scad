$fn = 128;

// Target dimensions (mm)
shank_d = 5.0;          // thread major diameter
length_L = 10.0;        // under-head length
head_d  = 10.0;         // head diameter
head_h  = 5.0;          // head height (parametric)

// Socket (approx for M5 SHCS)
socket_af    = 4.0;     // across flats (internal hex)
socket_depth = 3.0;

// Detailing
overlap = 0.25;         // overlap to guarantee watertight unions/differences
end_chamfer_h = 0.8;
end_chamfer_drop = 0.8; // radial reduction at tip over chamfer height

thread_pitch = 0.8;     // visual thread pitch (approx M5 coarse)
thread_depth = 0.35;    // visual thread depth (radial)
thread_start_clear = 0.6; // unthreaded runout under head
thread_slices_per_turn = 48;

// Z layout: under-head plane at z=0, shank extends to -length_L, head to +head_h
head_z0  = 0;
head_z1  = head_h;
shank_z0 = -length_L;
shank_z1 = 0;

// Helpers
function hex_pts(af) =
    [ for (i=[0:5]) [ (af/2)/cos(30) * cos(60*i), (af/2)/cos(30) * sin(60*i) ] ];

module hex_socket_cut() {
    // Internal hex socket cut from top face downward
    translate([0, 0, head_z1 - socket_depth/2 + overlap/2])
        linear_extrude(height=socket_depth + overlap, center=true)
            polygon(points=hex_pts(socket_af));
}

module shank_major() {
    // Major diameter cylinder for correct overall size
    translate([0, 0, (shank_z0 + shank_z1)/2])
        cylinder(h=length_L + overlap, r=shank_d/2, center=true);
}

module thread_ridges() {
    // Visual external thread: helical ridge swept around the shank
    thread_len = max(0, length_L - thread_start_clear);
    if (thread_len > 0) {
        turns = thread_len / thread_pitch;
        slices = max(24, ceil(turns * thread_slices_per_turn));

        // Place ridge so its outer edge reaches the major radius (shank_d/2)
        // Ridge radial thickness = thread_depth, so center at (major_r - thread_depth/2)
        major_r = shank_d/2;
        ridge_center_r = major_r - thread_depth/2;

        translate([0, 0, shank_z0 + thread_len/2])
            linear_extrude(height=thread_len, center=true, twist=-360*turns, slices=slices)
                translate([ridge_center_r, 0, 0])
                    square([thread_depth, thread_pitch*0.55], center=true);
    }
}

module shank_tip_chamfer() {
    // Chamfer at the tip (bottom end), overlaps into shank
    r_top = shank_d/2;
    r_bot = max(0.1, r_top - end_chamfer_drop);
    translate([0, 0, shank_z0 + end_chamfer_h/2])
        cylinder(h=end_chamfer_h + overlap, r1=r_bot, r2=r_top, center=true);
}

module shank() {
    // One connected solid: major cylinder + helical ridges + chamfer
    union() {
        shank_major();
        thread_ridges();
        shank_tip_chamfer();
    }
}

module head() {
    // Socket head cylinder
    translate([0, 0, (head_z0 + head_z1)/2])
        cylinder(h=head_h + overlap, r=head_d/2, center=true);
}

module socket_head_cap_screw() {
    difference() {
        union() {
            // Connected at z=0 plane (head starts at 0, shank ends at 0)
            head();
            shank();
        }
        // Internal hex socket
        hex_socket_cut();
    }
}

socket_head_cap_screw();