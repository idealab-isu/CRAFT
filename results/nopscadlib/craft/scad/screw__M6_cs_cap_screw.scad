// Socket head cap screw: 6mm shank, 12mm head diameter, 10mm long (under head)
// One connected solid, with hex socket and simplified external threads

$fn = 96;

// Parameters (mm)
shank_diameter_mm = 6;                 // major diameter
head_diameter_mm  = 12;
length_mm         = 10;                // under-head length
head_height_mm    = 6;

hex_socket_across_flats_mm = 5;
hex_socket_depth_mm        = 4.0;

thread_pitch_mm  = 1.0;
thread_depth_mm  = 0.35;               // simplified thread height (radial)
thread_length_mm = 10;                 // threaded length (<= length_mm)

tip_chamfer_mm   = 0.6;                // small end chamfer
underhead_chamfer_mm = 0.4;            // small under-head edge break

overlap_mm = 0.10;

// Helpers
function clamp(x, a, b) = x < a ? a : (x > b ? b : x);
function hex_circumradius_from_af(af) = (af/2)/cos(30);

// 2D profile for a simple triangular thread ridge (to be twisted with linear_extrude)
// IMPORTANT: polygon is defined in XY plane where X=radius, Y=z (pitch direction)
module thread_ridge_2d(r_root, depth, pitch) {
    polygon(points=[
        [r_root,          0],
        [r_root + depth,  pitch/2],
        [r_root,          pitch]
    ]);
}

module external_thread(major_d, pitch, depth, len) {
    r_major = major_d/2;
    r_root  = r_major - depth;
    turns   = (pitch > 0) ? (len / pitch) : 0;

    union() {
        // Root cylinder ensures a continuous solid core
        cylinder(r=r_root, h=len, center=false);

        // Helical ridge: rotate the 2D profile into XZ plane before extruding along Z
        // (Without this rotation, the ridge can end up degenerate/hidden in some viewers.)
        linear_extrude(
            height=len,
            twist=turns*360,
            slices=max(ceil(turns*24), 24),
            center=false,
            convexity=10
        )
            rotate([90,0,0])  // map 2D (x=radius,y=z) into 3D (x=radius,z=z)
                thread_ridge_2d(r_root=r_root, depth=depth, pitch=pitch);
    }
}

module socket_head_cap_screw() {
    thread_len = clamp(thread_length_mm, 0, length_mm);
    plain_len  = length_mm - thread_len;

    difference() {
        union() {
            // Head: z = 0 .. head_height
            cylinder(r=head_diameter_mm/2, h=head_height_mm, center=false);

            // Under-head chamfer: z = -underhead_chamfer .. 0 (connects head to shank)
            translate([0,0,-underhead_chamfer_mm])
                cylinder(r1=shank_diameter_mm/2, r2=head_diameter_mm/2,
                         h=underhead_chamfer_mm + overlap_mm, center=false);

            // Shank/threads: z = -length .. 0 (ensure overlap into under-head chamfer)
            translate([0,0,-length_mm]) {
                // Threaded portion at the tip end: z = 0 .. thread_len (local)
                if (thread_len > 0)
                    external_thread(major_d=shank_diameter_mm,
                                    pitch=thread_pitch_mm,
                                    depth=thread_depth_mm,
                                    len=thread_len);

                // Plain shank near head: z = thread_len .. length (local)
                if (plain_len > 0)
                    translate([0,0,thread_len - overlap_mm])
                        cylinder(r=shank_diameter_mm/2,
                                 h=plain_len + overlap_mm, center=false);
            }

            // Tip chamfer at very end: z = -length .. -length+tip_chamfer
            translate([0,0,-length_mm])
                cylinder(r1=0, r2=shank_diameter_mm/2,
                         h=tip_chamfer_mm + overlap_mm, center=false);
        }

        // Hex socket recess in head (from top face down)
        translate([0,0,head_height_mm - hex_socket_depth_mm])
            cylinder(r=hex_circumradius_from_af(hex_socket_across_flats_mm),
                     h=hex_socket_depth_mm + overlap_mm,
                     center=false, $fn=6);
    }
}

socket_head_cap_screw();