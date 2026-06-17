$fn = 128;

// Target: flexible shaft coupling, 6mm to 8mm stepped bore, 19mm OD, 25mm long

outer_diameter_mm = 19; //[10:38:0.1]
length_mm = 25; //[12.5:50:0.1]

bore1_diameter_mm = 6; //[3:12:0.1]   // left side (negative Z)
bore2_diameter_mm = 8; //[4:16:0.1]   // right side (positive Z)
bore1_depth_mm = 12.5; //[6:25:0.1]
bore2_depth_mm = 12.5; //[6:25:0.1]
bore_split_position_mm_from_center = 0; //[-5:5:0.1]

flex_cut_count = 6; //[3:12:1]
flex_cut_width_mm = 1.2; //[0.6:2.4:0.1]
flex_cut_depth_mm = 2.2; //[1:4:0.1]
flex_cut_pitch_mm = 6.0; //[3:12:0.1]
flex_cut_z_margin_mm = 2.0; //[0.5:5:0.1]

grub_screw_count_per_end = 2; //[0:4:1]
grub_screw_hole_diameter_mm = 3; //[2:5:0.1]
grub_screw_offset_from_ends_mm = 5; //[2.5:10:0.1]

clamp_slot_enable = 1; //[0:1:1]
clamp_slot_width_mm = 1.2; //[0.6:2.4:0.1]
clamp_slot_depth_mm = 1.0; //[0.5:3:0.1]  // radial depth into OD
clamp_slot_z_margin_mm = 1.0; //[0.5:4:0.1]

overlap_mm = 0.4; //[0.2:1:0.1]

// ---- Helpers ----
function clamp(x, a, b) = x < a ? a : (x > b ? b : x);

module helical_slot(z0, z1, r_mid, slot_w, slot_d, pitch, phase_deg) {
    steps = max(24, ceil((z1 - z0) * 6));
    dz = (z1 - z0) / steps;

    for (k = [0:steps-1]) {
        zA = z0 + k*dz;
        zB = z0 + (k+1)*dz;

        aA = phase_deg + (zA - z0) * 360 / pitch;
        aB = phase_deg + (zB - z0) * 360 / pitch;

        hull() {
            translate([0,0,zA])
                rotate([0,0,aA])
                    translate([r_mid,0,0])
                        cube([slot_d, slot_w, dz + 2*overlap_mm], center=true);

            translate([0,0,zB])
                rotate([0,0,aB])
                    translate([r_mid,0,0])
                        cube([slot_d, slot_w, dz + 2*overlap_mm], center=true);
        }
    }
}

module flexible_coupling_body() {
    r_out = outer_diameter_mm/2;

    z_min = -length_mm/2;
    z_max =  length_mm/2;

    // Split plane where the stepped bores meet
    z_split = clamp(bore_split_position_mm_from_center, z_min, z_max);

    // Force the two bores to meet (or slightly overlap) at the split plane
    bore1_end   = z_split + overlap_mm;
    bore1_start = clamp(bore1_end - bore1_depth_mm, z_min, z_max);
    bore1_h     = max(0, bore1_end - bore1_start);

    bore2_start = z_split - overlap_mm;
    bore2_end   = clamp(bore2_start + bore2_depth_mm, z_min, z_max);
    bore2_h     = max(0, bore2_end - bore2_start);

    // Flex cut region (avoid ends)
    z0 = z_min + flex_cut_z_margin_mm;
    z1 = z_max - flex_cut_z_margin_mm;

    // Place slots near OD but not through it
    r_mid = r_out - flex_cut_depth_mm/2;
    slot_d = flex_cut_depth_mm;
    slot_w = flex_cut_width_mm;

    // Clamp slit (axial) to visually/readably indicate clamp-style coupling
    slit_z0 = z_min + clamp_slot_z_margin_mm;
    slit_z1 = z_max - clamp_slot_z_margin_mm;
    slit_h  = max(0, slit_z1 - slit_z0);
    slit_r_mid = r_out - clamp_slot_depth_mm/2;

    difference() {
        // Main body (ONE connected solid)
        cylinder(h=length_mm, r=r_out, center=true);

        // Stepped bores (clearly different diameters on each half)
        if (bore1_h > 0)
            translate([0,0,(bore1_start + bore1_end)/2])
                cylinder(h=bore1_h + 2*overlap_mm, r=bore1_diameter_mm/2, center=true);

        if (bore2_h > 0)
            translate([0,0,(bore2_start + bore2_end)/2])
                cylinder(h=bore2_h + 2*overlap_mm, r=bore2_diameter_mm/2, center=true);

        // Helical flexure cuts
        for (i = [0:flex_cut_count-1]) {
            phase = i * 360 / flex_cut_count;
            helical_slot(z0, z1, r_mid, slot_w, slot_d, flex_cut_pitch_mm, phase);
        }

        // Axial clamp slit (does NOT fully sever the part; leaves material on opposite side)
        if (clamp_slot_enable && slit_h > 0) {
            translate([0,0,(slit_z0 + slit_z1)/2])
                rotate([0,0,0])
                    translate([slit_r_mid, 0, 0])
                        cube([clamp_slot_depth_mm + 2*overlap_mm,
                              clamp_slot_width_mm,
                              slit_h + 2*overlap_mm], center=true);
        }

        // Grub screw holes (radial), optional
        if (grub_screw_count_per_end > 0) {
            for (side = [-1, 1]) {
                z_pos = side * (length_mm/2 - grub_screw_offset_from_ends_mm);
                for (j = [0:grub_screw_count_per_end-1]) {
                    ang = j * 360 / grub_screw_count_per_end;
                    translate([0,0,z_pos])
                        rotate([0,0,ang])
                            rotate([0,90,0])
                                cylinder(h=outer_diameter_mm + 2*overlap_mm,
                                         r=grub_screw_hole_diameter_mm/2,
                                         center=true);
                }
            }
        }
    }
}

flexible_coupling_body();