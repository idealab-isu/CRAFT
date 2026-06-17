// Socket Head Cap Screw (single connected solid)
// Requested: shank Ø5.0mm, head Ø8.5mm, head height 5.0mm, overall length 10.0mm

shaft_diameter_mm = 5.0;
length_mm         = 10.0;   // overall length (under head + head)
head_diameter_mm  = 8.5;
head_height_mm    = 5.0;

socket_af_mm      = 4.0;    // hex across flats
socket_depth_mm   = 3.0;

thread_major_diameter_mm = 5.0;
thread_minor_diameter_mm = 4.2;
thread_pitch_mm          = 0.8;
threaded_length_mm       = 5.0;

overlap_mm = 0.2;
eps_mm     = 0.05;

$fn = 96;

// Hex prism sized by across-flats (AF)
module hex_prism_af(af, h, center=false) {
    r = af / sqrt(3); // circumradius for regular hex given AF
    cylinder(h=h, r=r, $fn=6, center=center);
}

// Simple external thread approximation (helical ridge) around a core
module simple_thread(major_d, minor_d, pitch, len) {
    core_r = minor_d/2;
    crest_r = major_d/2;
    ridge_h = max(0.01, crest_r - core_r);

    union() {
        // Core
        cylinder(h=len, r=core_r, center=false);

        // Helical ridge (triangular-ish via small rectangle)
        linear_extrude(height=len, twist=360*len/pitch, slices=max(24, ceil(len/pitch)*24), center=false)
            translate([core_r, 0, 0])
                square([ridge_h, pitch*0.35], center=false);
    }
}

module socket_head_cap_screw() {
    shank_len = length_mm - head_height_mm; // under-head length
    head_z0   = shank_len;                  // head starts at top of shank

    difference() {
        union() {
            // Shank with partial threading (connected to head)
            // Place shank from z=0..shank_len
            union() {
                // Unthreaded portion near head
                unthreaded_len = max(0, shank_len - threaded_length_mm);
                if (unthreaded_len > 0)
                    translate([0,0,0])
                        cylinder(h=unthreaded_len + overlap_mm, d=shaft_diameter_mm, center=false);

                // Threaded portion at tip end
                tlen = min(threaded_length_mm, shank_len);
                translate([0,0,unthreaded_len])
                    simple_thread(thread_major_diameter_mm, thread_minor_diameter_mm, thread_pitch_mm, tlen + overlap_mm);
            }

            // Head (connected; overlaps slightly into shank)
            translate([0,0,head_z0 - overlap_mm])
                cylinder(h=head_height_mm + overlap_mm, d=head_diameter_mm, center=false);
        }

        // Hex socket cut into head from top
        translate([0,0,head_z0 + head_height_mm - socket_depth_mm + eps_mm])
            hex_prism_af(socket_af_mm, socket_depth_mm + 2*eps_mm, center=false);
    }
}

socket_head_cap_screw();