// Socket head cap screw (single connected solid)
// Target: shank Ø6.0, head Ø10.0, head height 6.0, length under head 10.0

shank_diameter_mm = 6.0;
head_diameter_mm  = 10.0;
head_height_mm    = 6.0;
length_under_head_mm = 10.0;

// Typical M6 socket: 5mm across flats, recess depth ~4mm
hex_socket_af_mm     = 5.0;
hex_socket_depth_mm  = 4.0;

// Simple thread representation (visual only)
threaded = 1; // [0:1:1]
thread_major_diameter_mm = 6.0;
thread_minor_diameter_mm = 5.4;
thread_pitch_mm = 1.0;          // visual pitch
thread_depth_mm = 0.35;         // visual depth
thread_fn = 80;

overlap_mm = 0.2;

$fn = 96;

module hex_prism(af, h, center=false) {
    // For a regular hex: across flats = 2 * r * cos(30) => r = af/(2*cos(30))
    r = af/(2*cos(30));
    cylinder(r=r, h=h, center=center, $fn=6);
}

module threaded_shank_visual(d_major, d_minor, len) {
    // Base minor cylinder + shallow helical ridge to suggest threads
    union() {
        cylinder(d=d_minor, h=len, center=false, $fn=thread_fn);

        // Helical ridge (approximate)
        linear_extrude(height=len, twist=360*len/thread_pitch_mm, slices=max(ceil(len*12), 60), center=false)
            translate([d_minor/2 - overlap_mm, 0, 0])
                square([ (d_major - d_minor)/2 + thread_depth_mm, thread_depth_mm ], center=false);
    }
}

module socket_head_cap_screw() {
    // Coordinate system:
    // z=0 at underside of head; head extends +Z; shank extends -Z
    difference() {
        union() {
            // Head
            translate([0,0, head_height_mm/2])
                cylinder(d=head_diameter_mm, h=head_height_mm, center=true);

            // Shank / threaded portion (connected at z=0)
            if (threaded) {
                translate([0,0, -length_under_head_mm])
                    threaded_shank_visual(thread_major_diameter_mm, thread_minor_diameter_mm, length_under_head_mm);
            } else {
                translate([0,0, -length_under_head_mm/2])
                    cylinder(d=shank_diameter_mm, h=length_under_head_mm, center=true);
            }

            // Small under-head fillet (visual + ensures robust connection)
            translate([0,0, -overlap_mm])
                cylinder(d1=head_diameter_mm*0.92, d2=shank_diameter_mm, h=shank_diameter_mm*0.25 + overlap_mm, center=false);
        }

        // Hex socket recess (subtracted)
        // Top of head at z=head_height_mm; recess goes down by hex_socket_depth_mm
        translate([0,0, head_height_mm - hex_socket_depth_mm + overlap_mm])
            hex_prism(hex_socket_af_mm, hex_socket_depth_mm + 2*overlap_mm, center=false);

        // Slight chamfer at socket opening (subtracted)
        translate([0,0, head_height_mm - overlap_mm])
            cylinder(d1=hex_socket_af_mm*1.25, d2=hex_socket_af_mm*0.95, h=0.8 + 2*overlap_mm, center=false, $fn=48);
    }
}

socket_head_cap_screw();