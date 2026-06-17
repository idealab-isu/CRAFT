// Dome head screw with threads + optional drive recess
// Target: 4.0mm major diameter, 7.6mm head diameter, 2.2mm head height, 10mm under-head length

// Parameters
thread_diameter_mm = 4.0;   //[2.0:8.0:0.1]   // major diameter
length_mm          = 10.0;  //[5.0:30.0:0.5]  // under-head length
head_diameter_mm   = 7.6;   //[3.8:15.2:0.1]
head_height_mm     = 2.2;   //[1.1:6.0:0.1]

// Thread (simple ISO-like approximation)
pitch_mm           = 0.7;   //[0.4:1.5:0.05]
thread_depth_mm    = 0.35;  //[0.15:0.6:0.01] // radial depth from major to minor
thread_starts      = 1;     //[1:4]

// Drive recess (Phillips-like cross) - enabled by default
enable_drive       = true;
drive_width_mm     = 1.2;   //[0.6:2.5:0.05]
drive_length_mm    = 5.2;   //[2.0:7.0:0.1]
drive_depth_mm     = 1.4;   //[0.6:2.0:0.05]

// Quality / robustness
$fn = 128;
eps = 0.02;

module helical_thread_approx(d_major, L, pitch, depth, starts=1) {
    r_major = d_major/2;
    r_minor = max(r_major - depth, 0.01);

    // 2D profile in XZ plane (to be rotated around Z with twist)
    // A simple triangular-ish ridge between minor and major radii.
    // Keep profile slightly inside ends to avoid non-manifold caps.
    module thread_profile_2d() {
        polygon(points=[
            [r_minor, -pitch/2],
            [r_major, 0],
            [r_minor,  pitch/2]
        ]);
    }

    // Build multi-start by phase shifting along Z
    union() {
        for (s = [0:starts-1]) {
            z_phase = (pitch/starts) * s;
            translate([0,0,z_phase])
                linear_extrude(height=max(L - z_phase, 0), twist=360*(max(L - z_phase, 0))/pitch, slices=max(ceil((max(L - z_phase, 0))/pitch*24), 24))
                    thread_profile_2d();
        }
    }
}

module dome_head_screw(
    d_major = thread_diameter_mm,
    L = length_mm,
    d_head = head_diameter_mm,
    h_head = head_height_mm,
    pitch = pitch_mm,
    t_depth = thread_depth_mm,
    starts = thread_starts,
    drive_on = enable_drive,
    drive_w = drive_width_mm,
    drive_len = drive_length_mm,
    drive_depth = drive_depth_mm
) {
    r_major = d_major/2;
    r_head  = d_head/2;
    r_minor = max(r_major - t_depth, 0.01);

    // Spherical cap meeting base plane z=0 at radius r_head and top at z=h_head
    z0 = (h_head*h_head - r_head*r_head) / (2*h_head);
    R  = h_head - z0;

    // Small under-head relief to blend into threads
    relief_h = min(0.6, L*0.2);
    relief_r = r_major;

    difference() {
        union() {
            // Core (minor diameter) shaft for thread support: z=-L..0
            translate([0,0,-L/2])
                cylinder(h=L, r=r_minor, center=true);

            // Add helical thread ridges (approx): z=-L..0
            // Place so it fully covers the shaft length with slight overlap into head.
            translate([0,0,-L])
                helical_thread_approx(d_major=d_major, L=L + eps, pitch=pitch, depth=t_depth, starts=starts);

            // Under-head relief cylinder (major diameter) to ensure clean connection to head
            translate([0,0,-relief_h/2 + eps/2])
                cylinder(h=relief_h + eps, r=relief_r, center=true);

            // Dome head: spherical cap from z=0..h_head
            intersection() {
                translate([0,0,z0]) sphere(r=R);
                translate([0,0,h_head/2])
                    cube([d_head*2, d_head*2, h_head + 2*eps], center=true);
            }

            // Tiny overlap disk at z=0 to guarantee manifold union between head and shank
            translate([0,0,eps/2])
                cylinder(h=eps, r=r_head, center=true);
        }

        // Drive recess (cross slot) from top down
        if (drive_on) {
            depth = min(drive_depth, h_head - eps);
            // Two perpendicular slots, slightly tapered by hull of two rectangles
            translate([0,0,h_head - depth/2])
                union() {
                    // Slot 1
                    cube([drive_len, drive_w, depth + eps], center=true);
                    // Slot 2
                    cube([drive_w, drive_len, depth + eps], center=true);
                }
        }
    }
}

dome_head_screw();