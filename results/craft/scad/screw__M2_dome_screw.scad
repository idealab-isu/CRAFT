$fn = 96;

// Requested screw dimensions
shank_diameter_mm     = 2.0;
length_under_head_mm  = 10.0;
head_diameter_mm      = 3.5;
head_height_mm        = 1.3;

// Simple thread approximation (visual helical ridge)
thread_pitch_mm       = 0.40;   // approx for M2
thread_depth_mm       = 0.12;   // small ridge depth

// Tip
tip_chamfer_height_mm = 0.6;

// Connectivity overlap (1–2mm as required)
overlap_mm = 1.0;

module dome_head_profile(head_r, head_h) {
    // Spherical cap with base at z=0 and top at z=head_h, base radius=head_r
    // Sphere radius R = (a^2 + h^2) / (2h), where a=head_r, h=head_h
    R  = (head_r*head_r + head_h*head_h) / (2*head_h);
    zc = head_h - R; // sphere center z

    intersection() {
        translate([0,0,zc]) sphere(r=R);
        // Clip to cap height and base radius
        translate([0,0,head_h/2])
            cylinder(r=head_r, h=head_h + 2*overlap_mm, center=true);
    }
}

module threaded_shank(d, L) {
    r = d/2;
    turns = L / thread_pitch_mm;

    union() {
        // Core cylinder (minor diameter)
        cylinder(r=max(r - thread_depth_mm, 0.01), h=L);

        // Helical ridge (approx thread) along full length
        linear_extrude(height=L, twist=turns*360, slices=max(ceil(turns*24), 80))
            translate([r - thread_depth_mm/2, 0, 0])
                circle(r=thread_depth_mm/2);
    }
}

module screw_m2_dome(L_under, d_shank, d_head, h_head) {
    head_r  = d_head/2;
    shank_r = d_shank/2;

    // Ensure the shank penetrates into the head by overlap_mm (guaranteed connection)
    shank_len = L_under + overlap_mm;

    union() {
        // Head (base at z=0, top at z=h_head)
        dome_head_profile(head_r, h_head);

        // Shank + threads: top of shank at z=+overlap_mm (inside head), bottom at z=-L_under
        translate([0,0,-L_under])
            threaded_shank(d_shank, shank_len);

        // Tip chamfer at end of shank (bottom end), kept within shank length
        translate([0,0,-L_under])
            cylinder(r1=shank_r, r2=0, h=tip_chamfer_height_mm);
    }
}

screw_m2_dome(length_under_head_mm, shank_diameter_mm, head_diameter_mm, head_height_mm);