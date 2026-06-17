// M6 Grub screw (set screw) with hex socket and helical thread
// One connected solid, no floating parts, no arbitrary translates.

// ---------- Parameters ----------
thread_major_d = 6.0;          //[3.0:12.0:0.1]  Major diameter (M6 = 6)
thread_pitch   = 1.0;          //[0.5:2.0:0.05]  Pitch (M6 coarse = 1.0)
length_L       = 12.0;         //[6.0:24.0:0.5]  Overall length

hex_socket_af     = 3.0;       //[2.0:6.0:0.1]   Across flats
hex_socket_depth  = 3.0;       //[1.5:6.0:0.1]   Depth

thread_lead_chamfer = 0.6;     //[0.2:1.5:0.05]  Top chamfer
tip_chamfer         = 0.4;     //[0.1:1.0:0.05]  Bottom chamfer

// Thread geometry (approx ISO metric profile)
thread_depth = 0.6134 * thread_pitch;            // radial depth (approx)
thread_minor_d = thread_major_d - 2*thread_depth;

overlap = 0.2;                //[0.05:1.0:0.05]
$fn = 96;

// ---------- Helpers ----------
function clamp(x, a, b) = x < a ? a : (x > b ? b : x);

module hex_prism(af, h, center=false) {
    // Regular hex with across-flats = af
    // circumradius R = af / sqrt(3)
    R = af / sqrt(3);
    linear_extrude(height=h, center=center, convexity=10)
        polygon([ for (i=[0:5]) [ R*cos(60*i), R*sin(60*i) ] ]);
}

// ---------- Main geometry ----------
module screw_core() {
    // Core cylinder at minor diameter (thread root)
    cylinder(h=length_L, r=thread_minor_d/2, center=true);
}

module thread_helix() {
    // Triangular thread ridge swept helically around the core.
    // Use linear_extrude with twist; cross-section is a triangle located at major radius.
    turns = length_L / thread_pitch;
    // Place triangle so its outer vertex reaches major radius.
    // Triangle spans radially from (major - depth) to major.
    r_major = thread_major_d/2;
    r_root  = r_major - thread_depth;

    // Triangle in XY plane, centered in Z by linear_extrude(center=true)
    // Points: outer crest at r_major, two flanks at r_root with +/- pitch/2 in Y.
    linear_extrude(height=length_L, center=true, twist=turns*360, slices=ceil(turns*40), convexity=10)
        polygon(points=[
            [r_major, 0],
            [r_root,  thread_pitch/2],
            [r_root, -thread_pitch/2]
        ]);
}

module end_chamfers() {
    // Chamfer both ends by subtracting cones
    difference() {
        // placeholder; used only as subtractor in main difference
        cylinder(h=length_L + 2*overlap, r=thread_major_d/2 + 1, center=true);
        // keep nothing
    }
}

module chamfer_subtractors() {
    r = thread_major_d/2 + 0.01;

    // Top chamfer (near +Z)
    translate([0,0, length_L/2 - thread_lead_chamfer/2 + overlap/2])
        cylinder(h=thread_lead_chamfer + overlap, r1=r, r2=r - thread_lead_chamfer, center=true);

    // Bottom chamfer (near -Z)
    translate([0,0, -length_L/2 + tip_chamfer/2 - overlap/2])
        cylinder(h=tip_chamfer + overlap, r1=r - tip_chamfer, r2=r, center=true);
}

module hex_socket_cut() {
    // Cut hex socket from the top face inward
    translate([0,0, length_L/2 - hex_socket_depth/2])
        hex_prism(hex_socket_af, hex_socket_depth + overlap, center=true);
}

module grub_screw() {
    // Build as union(core + thread), then subtract socket and chamfers.
    difference() {
        union() {
            screw_core();
            thread_helix();
        }

        // Internal drive
        hex_socket_cut();

        // End chamfers (subtractive)
        chamfer_subtractors();
    }
}

// ---------- Output ----------
color("DimGray") grub_screw();