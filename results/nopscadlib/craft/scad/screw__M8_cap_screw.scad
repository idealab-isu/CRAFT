$fn = 128;

// Socket head cap screw dimensions (mm)
shaft_diameter_mm = 8.0;      // shank major diameter
head_diameter_mm  = 13.0;     // head diameter
head_height_mm    = 8.0;      // head height
overall_length_mm = 10.0;     // length under head

// Internal hex socket (Allen)
socket_af_mm    = 6.0;        // across flats
socket_depth_mm = 5.0;        // recess depth

// Simple visual thread approximation (not a true helical thread)
thread_minor_diameter_mm = 7.0;
thread_pitch_mm          = 1.25;

overlap_mm = 0.2;

function hex_r_from_af(af) = af / (2*cos(30)); // circumradius for hex polygon

module hex_prism(af, h) {
    r = hex_r_from_af(af);
    linear_extrude(height=h, center=false)
        polygon(points=[for(i=[0:5]) [r*cos(60*i), r*sin(60*i)]]);
}

module approx_threads(len, major_d, minor_d, pitch) {
    turns  = max(1, floor(len/pitch));
    rings  = turns * 2;
    ring_h = len / rings;

    union() {
        // core
        cylinder(h=len, r=minor_d/2, center=false);

        // raised rings to suggest threads
        for (i=[0:rings-1]) {
            z0 = i * ring_h;
            translate([0,0,z0])
                cylinder(h=ring_h*0.85, r=major_d/2, center=false);
        }
    }
}

module socket_head_cap_screw() {
    // Z=0 at underside of head; head extends +Z, shank extends -Z
    difference() {
        union() {
            // Head
            cylinder(h=head_height_mm, r=head_diameter_mm/2, center=false);

            // Shank (connected to head at Z=0, extends down to -overall_length_mm)
            translate([0,0,-overall_length_mm])
                approx_threads(overall_length_mm, shaft_diameter_mm, thread_minor_diameter_mm, thread_pitch_mm);
        }

        // Internal hex socket recess (cut into head from top surface)
        translate([0,0,head_height_mm - socket_depth_mm])
            hex_prism(socket_af_mm, socket_depth_mm + overlap_mm);
    }
}

socket_head_cap_screw();