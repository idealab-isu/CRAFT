// Socket head cap screw — 3.0mm shank, 6.0mm head, 10mm under-head length
// One connected solid, internal hex socket recess, no flange/washer feature.

$fn = 96;

// Parameters (mm)
thread_diameter_mm = 3.0;
length_mm          = 10.0;   // under-head length
head_diameter_mm   = 6.0;
head_height_mm     = 3.0;

hex_socket_af_mm    = 2.5;   // across flats (visual)
hex_socket_depth_mm = 1.8;

head_to_shaft_chamfer_h_mm = 0.6;

thread_pitch_mm   = 0.5;
thread_depth_mm   = 0.25;    // radial depth (visual)
thread_runout_mm  = 1.0;     // unthreaded near head

overlap_mm = 0.05;

// Derived
shank_r = thread_diameter_mm/2;
head_r  = head_diameter_mm/2;

module hex_prism_af(af, h, center=false) {
    // For hex: circumradius R = AF / (2*cos(30))
    cylinder(h=h, r=af/(2*cos(30)), $fn=6, center=center);
}

module helical_thread(major_d, pitch, length, depth, slices_per_turn=28) {
    major_r = major_d/2;
    minor_r = major_r - depth;

    // 2D profile (X=radius, Y=axis within one pitch)
    profile = [
        [minor_r, -pitch/2],
        [major_r,  0],
        [minor_r,  pitch/2]
    ];

    turns = length / pitch;
    steps = max(ceil(turns * slices_per_turn), 12);

    linear_extrude(height=length, twist=turns*360, slices=steps, convexity=10)
        polygon(points=profile);
}

module screw() {
    // z=0 at underside of head
    // head: 0..+head_height_mm
    // shank/thread: 0..-length_mm

    difference() {
        union() {
            // Head (cylindrical, no flange)
            translate([0, 0, head_height_mm/2])
                cylinder(r=head_r, h=head_height_mm, center=true);

            // Under-head chamfer (connect head to shank without creating a flange)
            // Starts at z=0 and goes down to z=-head_to_shaft_chamfer_h_mm
            translate([0, 0, -head_to_shaft_chamfer_h_mm/2])
                cylinder(r1=shank_r, r2=head_r, h=head_to_shaft_chamfer_h_mm + overlap_mm, center=true);

            // Core shank at minor diameter (ensures one connected solid)
            minor_r  = shank_r - thread_depth_mm;
            core_len = length_mm;
            translate([0, 0, -core_len/2])
                cylinder(r=minor_r, h=core_len + overlap_mm, center=true);

            // Unthreaded runout near head at major diameter
            if (thread_runout_mm > 0) {
                translate([0, 0, -thread_runout_mm/2])
                    cylinder(r=shank_r, h=thread_runout_mm + overlap_mm, center=true);
            }

            // Helical external thread (starts after runout, extends to tip)
            thread_len = max(length_mm - thread_runout_mm, 0);
            if (thread_len > 0) {
                translate([0, 0, -(thread_runout_mm + thread_len)])
                    helical_thread(
                        major_d = thread_diameter_mm,
                        pitch   = thread_pitch_mm,
                        length  = thread_len + overlap_mm,
                        depth   = thread_depth_mm,
                        slices_per_turn = 32
                    );
            }
        }

        // Internal hex socket recess (subtracted from head)
        translate([0, 0, head_height_mm - hex_socket_depth_mm/2 + overlap_mm/2])
            hex_prism_af(hex_socket_af_mm, hex_socket_depth_mm + overlap_mm, center=true);
    }
}

screw();