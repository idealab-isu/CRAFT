$fn = 96;

// Target screw dimensions (mm)
shaft_diameter_mm      = 2.0;   // shank major diameter
length_under_head_mm   = 10.0;  // length from underside of head to tip
head_diameter_mm       = 3.5;   // dome head max diameter
head_height_mm         = 1.3;   // head height above underside

// Thread (simple helical approximation)
thread_pitch_mm        = 0.45;  // typical for M2-ish
thread_depth_mm        = 0.12;  // radial height of thread ridge
thread_length_mm       = 10.0;  // threaded along full shank

// Small overlap to ensure one connected solid
overlap_mm             = 0.05;

// Hex socket recess (kept small; does not affect outer dims)
hex_socket_af_mm       = 1.5;
hex_socket_depth_mm    = 0.8;

// Helpers
function clamp(x, a, b) = x < a ? a : (x > b ? b : x);

module dome_head(od, h) {
    // Spherical cap: base plane at z=0, top at z=h, max diameter = od
    // Sphere radius R = (a^2 + h^2)/(2h), where a = od/2
    a = od/2;
    R = (a*a + h*h) / (2*h);
    zc = h - R; // sphere center z so that cap top is at z=h

    intersection() {
        translate([0,0,zc]) sphere(r=R);
        // keep only z in [0, h]
        translate([0,0,h/2]) cube([od*2, od*2, h], center=true);
    }
}

module hex_socket_recess(af, depth) {
    // Hex prism (point-to-point radius = af/(2*cos30))
    r_hex = af/(2*cos(30));
    cylinder(h=depth, r=r_hex, center=false, $fn=6);
}

module simple_thread(major_d, pitch, depth, len) {
    // Helical ridge around a core cylinder; unioned to form external thread.
    // This is a visual/printable approximation, not a standards-accurate profile.
    major_r = major_d/2;
    core_r  = major_r - depth;

    turns = len / pitch;
    steps_per_turn = 24;
    slices = max(12, ceil(turns * steps_per_turn));
    dz = len / slices;
    dtheta = 360 * turns / slices;

    union() {
        // Core
        cylinder(h=len, r=core_r, center=false);

        // Helical ridge as a chain of slightly overlapping "teeth"
        for (i = [0:slices-1]) {
            z = i * dz;
            theta = i * dtheta;

            // Tooth dimensions
            tooth_h = dz + overlap_mm;
            tooth_t = depth * 1.6;                 // tangential thickness
            tooth_r = depth * 1.2;                 // radial thickness

            translate([0,0,z])
                rotate([0,0,theta])
                    translate([core_r + tooth_r/2, 0, 0])
                        cube([tooth_r, tooth_t, tooth_h], center=true);
        }
    }
}

module screw() {
    // Coordinate system:
    // underside of head at z=0
    // head extends to +head_height_mm
    // shank extends to -length_under_head_mm
    difference() {
        union() {
            // Dome head
            dome_head(head_diameter_mm, head_height_mm);

            // Shank with threads (connected with slight overlap into head)
            translate([0,0,-length_under_head_mm - overlap_mm])
                simple_thread(shaft_diameter_mm, thread_pitch_mm, thread_depth_mm, length_under_head_mm + overlap_mm);
        }

        // Hex socket recess cut into head from the top
        translate([0,0,head_height_mm - hex_socket_depth_mm])
            hex_socket_recess(hex_socket_af_mm, hex_socket_depth_mm + overlap_mm);
    }
}

// Output: one connected solid (the screw)
screw();