$fn = 64;

// Overall envelope (must match request)
width_mm  = 120;  // X
depth_mm  = 88;   // Y
height_mm = 120;  // Z

// Base / feet
foot_thickness_mm     = 6;
foot_overhang_x_mm    = 10;
foot_overhang_y_mm    = 8;
mount_hole_d_mm       = 7;
mount_hole_inset_x_mm = 18;
mount_hole_inset_y_mm = 14;

// Core / coil proportions
lamination_height_mm     = 80;
lamination_width_ratio   = 0.82;
lamination_depth_ratio   = 0.72;

bobbin_width_ratio                 = 0.58;
bobbin_depth_ratio                 = 0.92;
bobbin_height_ratio_of_lamination  = 0.88;

// Top terminal block + posts
terminal_block_height_ratio_of_remaining = 0.55;
terminal_block_width_ratio  = 0.62;
terminal_block_depth_ratio  = 0.55;

post_d_mm = 3.2;
post_h_mm = 10;
post_rows = 2;
post_cols = 4;
post_pitch_x_mm = 10;
post_pitch_y_mm = 10;

connect_overlap_mm = 1;

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

module rounded_box(size=[10,10,10], r=2, center=true) {
    r2 = min(r, min(size[0], min(size[1], size[2]))/2);
    // Guard against zero/negative minkowski core (can cause empty/blank renders)
    core = [
        max(0.01, size[0] - 2*r2),
        max(0.01, size[1] - 2*r2),
        max(0.01, size[2] - 2*r2)
    ];
    translate(center ? [0,0,0] : [size[0]/2, size[1]/2, size[2]/2])
        minkowski() {
            cube(core, center=true);
            sphere(r=r2);
        }
}

module transformer() {
    // Derived sizes
    base_w = width_mm + 2*foot_overhang_x_mm;
    base_d = depth_mm + 2*foot_overhang_y_mm;
    base_h = foot_thickness_mm;

    lam_w = width_mm * lamination_width_ratio;
    lam_d = depth_mm * lamination_depth_ratio;
    lam_h = lamination_height_mm;

    bob_w = width_mm * bobbin_width_ratio;
    bob_d = depth_mm * bobbin_depth_ratio;
    bob_h = lam_h * bobbin_height_ratio_of_lamination;

    remaining_h = height_mm - base_h - lam_h;
    term_h = clamp(remaining_h * terminal_block_height_ratio_of_remaining, 6, remaining_h);
    term_w = width_mm * terminal_block_width_ratio;
    term_d = depth_mm * terminal_block_depth_ratio;

    // Z placement (centered overall)
    z_base_c = -height_mm/2 + base_h/2;
    z_lam_c  = -height_mm/2 + base_h + lam_h/2 - connect_overlap_mm;
    z_bob_c  = z_lam_c; // centered within lamination stack
    z_term_c = -height_mm/2 + base_h + lam_h + term_h/2 - connect_overlap_mm;

    // Terminal posts placement
    posts_total_w = (post_cols-1)*post_pitch_x_mm;
    posts_total_d = (post_rows-1)*post_pitch_y_mm;
    posts_origin_z = z_term_c + term_h/2 + post_h_mm/2 - connect_overlap_mm;

    // Mount hole positions
    hole_x = base_w/2 - mount_hole_inset_x_mm;
    hole_y = base_d/2 - mount_hole_inset_y_mm;

    // Coil flanges
    flange_t = 3;
    flange_over_x = 6;
    flange_over_y = 4;

    // Side mounting ears (small brackets) connected to base
    ear_t = 4;
    ear_h = 14;
    ear_d = 18;
    ear_x = base_w/2 - ear_t/2 + connect_overlap_mm;

    // Core window detail
    win_w = lam_w * 0.42;
    win_d = lam_d * 0.55;
    win_h = lam_h * 0.78;

    // Build as ONE connected solid (no separate duplicate lamination block)
    union() {
        // Base plate with mounting holes
        difference() {
            translate([0,0,z_base_c])
                rounded_box([base_w, base_d, base_h], r=2.5, center=true);

            for (sx = [-1, 1], sy = [-1, 1]) {
                translate([sx*hole_x, sy*hole_y, z_base_c])
                    cylinder(d=mount_hole_d_mm, h=base_h + 2, center=true);
            }
        }

        // Lamination stack with window cut (single solid, not duplicated)
        difference() {
            translate([0,0,z_lam_c])
                rounded_box([lam_w, lam_d, lam_h], r=2, center=true);

            translate([0,0,z_lam_c])
                rounded_box([win_w, win_d, win_h], r=1.5, center=true);
        }

        // Bobbin / coil pack
        translate([0,0,z_bob_c])
            rounded_box([bob_w, bob_d, bob_h], r=2, center=true);

        // Coil flanges (top/bottom lips) - overlap into bobbin
        translate([0,0, z_bob_c + bob_h/2 - flange_t/2 + connect_overlap_mm])
            rounded_box([bob_w + flange_over_x, bob_d + flange_over_y, flange_t], r=1.5, center=true);

        translate([0,0, z_bob_c - bob_h/2 + flange_t/2 - connect_overlap_mm])
            rounded_box([bob_w + flange_over_x, bob_d + flange_over_y, flange_t], r=1.5, center=true);

        // Terminal block
        translate([0,0,z_term_c])
            rounded_box([term_w, term_d, term_h], r=2, center=true);

        // Terminal posts (pins) - connected to terminal block
        for (r = [0:post_rows-1], c = [0:post_cols-1]) {
            px = (c*post_pitch_x_mm - posts_total_w/2);
            py = (r*post_pitch_y_mm - posts_total_d/2);
            translate([px, py, posts_origin_z])
                cylinder(d=post_d_mm, h=post_h_mm, center=true);
        }

        // Side mounting ears - connected to base
        for (sx = [-1, 1]) {
            translate([sx*ear_x, 0, z_base_c + base_h/2 + ear_h/2 - connect_overlap_mm])
                rounded_box([ear_t, ear_d, ear_h], r=1.5, center=true);
        }
    }
}

transformer();