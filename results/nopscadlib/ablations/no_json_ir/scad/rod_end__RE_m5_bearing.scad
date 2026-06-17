// uxcell M5x0.8 Right Hand Thread - Rod End (simplified but recognizable)
// One connected solid: eye/head with through-bore + spherical insert + threaded shank + wrench flats
// No arbitrary translate values: all derived from dimensions.

$fn = 96;

// -------------------- Parameters --------------------
m_thread_d = 5;          // M5 major diameter
thread_pitch = 0.8;      // M5x0.8
shank_length = 20;

wrench_flat_width = 8;   // across flats (approx)
wrench_flat_length = 6;  // length of wrench section near eye

eye_outer_d = 16;        // outer diameter of eye/head
eye_thickness = 6;       // thickness of eye along shank axis

ball_d = 10;             // spherical insert OD (visual)
bore_d = 5.2;            // through-bore in ball (approx clearance)
ball_seat_clear = 0.25;  // clearance between ball and housing cavity

neck_d = 8;              // neck between eye and shank
neck_len = 3;

fillet_len = 2;          // transition length from neck to shank

// Thread visual detail (approx)
thread_depth = 0.35;     // radial depth of thread ridge
thread_turns = shank_length / thread_pitch;
thread_slices = max(24, ceil(thread_turns * 18)); // resolution along helix

// Overlap to ensure watertight unions
ov = 0.25;

// -------------------- Helpers --------------------
module hex_prism(af, h, center=false) {
    // Regular hex with across-flats = af
    r = af / sqrt(3); // circumradius
    cylinder(r=r, h=h, $fn=6, center=center);
}

module external_thread_visual(d_major, pitch, length, depth) {
    // Simple right-hand helical ridge around a core cylinder.
    // Not a standards-accurate ISO thread, but clearly shows M5x0.8 RH thread.
    core_d = d_major - 2*depth;
    union() {
        cylinder(d=core_d, h=length, center=false);

        // Helical ridge made by twisting a small rectangular strip
        // placed at radius = core/2 and twisted over length.
        linear_extrude(height=length, twist=360*(length/pitch), slices=thread_slices, center=false)
            translate([core_d/2, 0, 0])
                square([depth*2, pitch*0.55], center=true);
    }
}

module eye_housing() {
    // Eye/head with spherical seat cavity and through-bore
    difference() {
        // Outer eye
        cylinder(d=eye_outer_d, h=eye_thickness, center=true);

        // Spherical seat cavity (slightly larger than ball)
        sphere(d=ball_d + 2*ball_seat_clear);

        // Through-bore (goes through eye and ball)
        rotate([90, 0, 0])
            cylinder(d=bore_d, h=eye_outer_d + 2, center=true);
    }
}

module spherical_insert() {
    // Ball insert with through-bore; kept as solid part of assembly (union),
    // but slightly smaller than cavity so it doesn't self-intersect.
    difference() {
        sphere(d=ball_d);
        rotate([90, 0, 0])
            cylinder(d=bore_d, h=ball_d + 2, center=true);
    }
}

module shank_and_transitions() {
    // Build from eye bottom face downward (negative Z)
    // Eye is centered at Z=0, so bottom face is at -eye_thickness/2.
    z0 = -eye_thickness/2;

    union() {
        // Neck directly under eye (connected with overlap)
        translate([0, 0, z0 - neck_len/2 + ov/2])
            cylinder(d=neck_d, h=neck_len + ov, center=true);

        // Transition from neck to shank (taper)
        translate([0, 0, z0 - neck_len - fillet_len/2 + ov/2])
            cylinder(d1=neck_d, d2=m_thread_d, h=fillet_len + ov, center=true);

        // Wrench flats section (hex) near eye
        // Positioned so its top slightly overlaps the neck.
        translate([0, 0, z0 - neck_len - wrench_flat_length/2 + ov/2])
            hex_prism(wrench_flat_width, wrench_flat_length + ov, center=true);

        // Threaded shank starts below wrench section
        thread_start_z = z0 - neck_len - wrench_flat_length;
        translate([0, 0, thread_start_z - shank_length + ov])
            external_thread_visual(m_thread_d, thread_pitch, shank_length + ov, thread_depth);
    }
}

// -------------------- Assembly --------------------
module rod_end_bearing() {
    union() {
        eye_housing();
        spherical_insert();
        shank_and_transitions();
    }
}

rod_end_bearing();