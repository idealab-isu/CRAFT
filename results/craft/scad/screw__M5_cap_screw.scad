// Socket head cap screw (single connected solid)
// Requested: shank Ø5.0, head Ø8.5, head height 5.0, length under head 10.0

$fn = 128;

// Dimensions (mm)
thread_diameter_mm = 5.0;   // major diameter
length_under_head_mm = 10.0;
head_diameter_mm   = 8.5;
head_height_mm     = 5.0;

// Connectivity overlap (1-2mm to guarantee attachment)
overlap_mm = 1.2;

// Thread (visual approximation)
thread_pitch_mm = 0.8;                 // ~M5 coarse
thread_depth_mm = 0.35;                // radial depth of thread ridges (visual)
thread_segments_per_turn = 28;         // smoothness of helix

// Hex socket (approx for M5: 4mm AF, depth ~3mm)
hex_socket_af_mm = 4.0;
hex_socket_depth_mm = 3.0;
hex_socket_clearance_mm = 0.15;

// Small edge breaks
head_top_chamfer_mm = 0.35;
head_bottom_chamfer_mm = 0.45;

module helical_thread_ridges(major_d, length, pitch, ridge_depth, segs_per_turn) {
    // Creates a continuous helical ridge around a cylinder (visual thread)
    major_r = major_d/2;
    turns = length / pitch;
    steps = max(8, ceil(turns * segs_per_turn));
    dz = length / steps;
    dtheta = 360 * turns / steps;

    // Ridge cross-section (tangential width and radial thickness)
    ridge_tan_w = pitch * 0.45;
    ridge_rad_t = ridge_depth;

    union() {
        for (i = [0:steps-1]) {
            z0 = -length/2 + i*dz;
            z1 = z0 + dz + overlap_mm;

            hull() {
                rotate([0,0,i*dtheta])
                    translate([major_r - ridge_rad_t/2, 0, z0])
                        cube([ridge_rad_t, ridge_tan_w, overlap_mm], center=true);

                rotate([0,0,(i+1)*dtheta])
                    translate([major_r - ridge_rad_t/2, 0, z1])
                        cube([ridge_rad_t, ridge_tan_w, overlap_mm], center=true);
            }
        }
    }
}

module socket_head_cap_screw() {
    shank_r = thread_diameter_mm/2;
    head_r  = head_diameter_mm/2;

    // --- FIX: Recalculate Z placement so head and shank OVERLAP (no gap) ---
    // Place head centered at z=0, spanning [-head_h/2, +head_h/2]
    head_zc = 0;

    // Place shank so its TOP is inside the head by overlap_mm:
    // shank_top_z = -head_h/2 + overlap_mm
    // shank_center_z = shank_top_z - shank_h/2
    shank_h = length_under_head_mm + overlap_mm; // extend into head for guaranteed union
    shank_top_z = -head_height_mm/2 + overlap_mm;
    shank_zc = shank_top_z - shank_h/2;

    // Hex socket cut (kept within head; no effect on connectivity)
    socket_af = hex_socket_af_mm + hex_socket_clearance_mm;
    socket_r  = (socket_af / cos(30)) / 2; // circumradius for hex
    socket_h  = hex_socket_depth_mm + overlap_mm;
    socket_top_z = head_height_mm/2 + overlap_mm; // ensure it reaches the top face
    socket_zc = socket_top_z - socket_h/2;

    // Shank core (minor-ish) to support thread ridges
    core_r = max(0.01, shank_r - thread_depth_mm);

    difference() {
        union() {
            // Head
            translate([0,0,head_zc])
                cylinder(r=head_r, h=head_height_mm, center=true);

            // Shank core (extended into head by overlap_mm)
            translate([0,0,shank_zc])
                cylinder(r=core_r, h=shank_h, center=true);

            // Thread ridges (visual) - same placement/length as shank core for solid union
            translate([0,0,shank_zc])
                helical_thread_ridges(thread_diameter_mm,
                                      shank_h,
                                      thread_pitch_mm,
                                      thread_depth_mm,
                                      thread_segments_per_turn);
        }

        // Internal hex socket recess (6-sided)
        translate([0,0,socket_zc])
            linear_extrude(height=socket_h, center=true)
                circle(r=socket_r, $fn=6);

        // Head top chamfer (edge break)
        translate([0,0, head_height_mm/2 - head_top_chamfer_mm/2 + overlap_mm])
            cylinder(r1=head_r + 0.01, r2=max(0.01, head_r - head_top_chamfer_mm),
                     h=head_top_chamfer_mm + overlap_mm, center=true);

        // Head bottom chamfer (edge break)
        translate([0,0, -head_height_mm/2 + head_bottom_chamfer_mm/2 - overlap_mm])
            cylinder(r1=max(0.01, head_r - head_bottom_chamfer_mm), r2=head_r + 0.01,
                     h=head_bottom_chamfer_mm + overlap_mm, center=true);
    }
}

socket_head_cap_screw();