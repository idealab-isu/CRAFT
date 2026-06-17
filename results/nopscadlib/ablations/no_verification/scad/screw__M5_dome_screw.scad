$fn = 140;

// Parameters (mm)
shaft_diameter_mm      = 5.0;   // major diameter
length_under_head_mm   = 10.0;  // from underside of head to tip
head_diameter_mm       = 9.5;
head_height_mm         = 2.75;

hex_socket_af_mm       = 4.0;
hex_socket_depth_mm    = 2.0;

tip_length_mm          = 1.2;
overlap_mm             = 0.25;

// Visual thread (approx)
thread_pitch_mm        = 1.0;
thread_depth_mm        = 0.35;  // radial height of ridge
thread_clearance_mm    = 0.05;  // keep ridge slightly inside major dia to avoid artifacts
thread_start_from_head_mm = 0.2; // start a bit below head underside
thread_end_before_tip_mm  = 0.2; // end a bit above tip

function hex_r_from_af(af) = af / (2 * cos(30));

module dome_head_screw() {
    shaft_r = shaft_diameter_mm / 2;
    head_r  = head_diameter_mm / 2;

    // Coordinate system:
    // underside of head at z=0
    // head extends to +z
    // shank/tip extend to -z
    shank_len = length_under_head_mm - tip_length_mm;

    // Thread region along shank (exclude a little near head and tip)
    thread_z_top = -thread_start_from_head_mm;
    thread_z_bot = -(length_under_head_mm - tip_length_mm - thread_end_before_tip_mm);
    thread_h     = max(0, thread_z_top - thread_z_bot);

    difference() {
        // ONE connected solid: head + shank + tip + thread ridge
        union() {
            // Shank (connected to head at z=0)
            translate([0, 0, -shank_len/2])
                cylinder(h = shank_len + overlap_mm, r = shaft_r, center = true);

            // Conical tip (connected to shank end)
            translate([0, 0, -shank_len - tip_length_mm/2 + overlap_mm])
                cylinder(h = tip_length_mm + overlap_mm, r1 = shaft_r, r2 = 0, center = true);

            // Dome head as spherical cap with exact height, base at z=0
            // Sphere center at z = head_height - sqrt(head_r^2 - base_r^2), with base_r = head_r
            // For a cap with base radius = head_r, this simplifies to center at z = head_height
            // and we keep z in [0, head_height].
            intersection() {
                translate([0, 0, head_height_mm])
                    sphere(r = head_r);
                translate([0, 0, head_height_mm/2])
                    cube([head_diameter_mm*2.2, head_diameter_mm*2.2, head_height_mm], center = true);
            }

            // Visual helical thread ridge (adds material), connected to shank
            if (thread_h > 0.01) {
                turns = thread_h / thread_pitch_mm;
                translate([0, 0, thread_z_bot])
                    linear_extrude(
                        height = thread_h,
                        twist = 360 * turns,
                        slices = max(ceil(80 * turns), 80),
                        convexity = 10
                    )
                    translate([shaft_r - thread_depth_mm - thread_clearance_mm, 0, 0])
                        polygon(points=[
                            [0, -thread_pitch_mm*0.22],
                            [thread_depth_mm, 0],
                            [0,  thread_pitch_mm*0.22]
                        ]);
            }
        }

        // Hex socket cavity (subtracted from head only)
        translate([0, 0, head_height_mm - hex_socket_depth_mm/2 + overlap_mm])
            cylinder(
                h = hex_socket_depth_mm + overlap_mm*2,
                r = hex_r_from_af(hex_socket_af_mm),
                center = true,
                $fn = 6
            );
    }
}

dome_head_screw();