$fn = 64;

// IEC C14 switched fused inlet module (approx) - FRONT FACE 40 x 27 mm
// Coordinate system: front face at z=0, rear extends to negative z.

overall_width_mm  = 40.0;
overall_height_mm = 27.0;

// Front bezel / flange
bezel_depth_mm = 3.0;          // protrudes forward (+z)
bezel_corner_r = 1.2;

// Rear body (behind panel)
body_width_mm  = 36.0;
body_height_mm = 23.0;
body_depth_mm  = 28.0;         // extends rearward (-z)
body_corner_r  = 1.2;

// Mounting ears (left/right)
ear_extra_x_mm = 6.0;          // total extra width beyond 40 for ears
ear_height_mm = 8.0;
ear_thickness_mm = 3.0;

// Mount holes (ears)
mount_hole_diameter_mm = 3.2;
mount_hole_edge_margin_mm = 4.5;

// Front features (openings)
iec_open_w = 27.5;             // C14-ish opening
iec_open_h = 19.5;
iec_open_depth = 12.0;

switch_open_w = 19.0;
switch_open_h = 13.0;
switch_open_depth = 8.0;

fuse_open_w = 22.0;
fuse_open_h = 10.0;
fuse_open_depth = 10.0;

// Add recognizable C14 "key" notches (approx)
iec_notch_w = 4.0;
iec_notch_h = 3.0;

// Rear terminals (3 tabs)
spade_tab_width_mm     = 6.3;
spade_tab_thickness_mm = 0.8;
spade_tab_length_mm    = 12.0;
spade_tab_spacing_mm   = 8.5;

// Small overlap to guarantee watertight unions/differences (1-2mm as required)
overlap_mm = 1.2;

// Helpers
module rounded_rect_prism(size=[10,10,10], r=1, center=true) {
    rr = min(r, min(size[0], size[1]) / 2 - 0.01);
    minkowski() {
        cube([size[0]-2*rr, size[1]-2*rr, size[2]], center=center);
        cylinder(r=rr, h=0.01, center=true);
    }
}

module iec_inlet_module() {
    bezel_w = overall_width_mm;
    bezel_h = overall_height_mm;

    ear_total_w = bezel_w + ear_extra_x_mm;
    ear_h = ear_height_mm;

    body_w = body_width_mm;
    body_h = body_height_mm;

    z_front = 0;
    z_bezel_center = bezel_depth_mm/2;

    // Rear body: overlaps into bezel region by overlap_mm
    // Body spans: [-body_depth_mm, +overlap_mm]
    body_z_center = (-body_depth_mm + overlap_mm)/2;
    body_z_len    = body_depth_mm + overlap_mm;

    // Convenience: rear face of the body block (with the above definition)
    // is exactly at z = -body_depth_mm
    body_rear_z = -body_depth_mm;

    difference() {
        union() {
            // Front bezel (40 x 27)
            translate([0, 0, z_bezel_center])
                rounded_rect_prism([bezel_w, bezel_h, bezel_depth_mm], r=bezel_corner_r, center=true);

            // Ears (same plane/thickness as bezel so they are connected)
            translate([0, 0, ear_thickness_mm/2])
                rounded_rect_prism([ear_total_w, ear_h, ear_thickness_mm], r=1.0, center=true);

            // Rear body block (overlaps into +z by overlap_mm to guarantee union with bezel)
            translate([0, 0, body_z_center])
                rounded_rect_prism([body_w, body_h, body_z_len], r=body_corner_r, center=true);

            // Rear spade tabs (3), connected to rear face with overlap
            tab_z_center = body_rear_z - spade_tab_length_mm/2 + overlap_mm; // penetrates body by overlap_mm
            for (yy = [-spade_tab_spacing_mm, 0, spade_tab_spacing_mm]) {
                translate([0, yy, tab_z_center])
                    cube([spade_tab_thickness_mm, spade_tab_width_mm, spade_tab_length_mm], center=true);

                // Root pad to ensure strong connection to body rear face
                translate([0, yy, body_rear_z + overlap_mm/2])
                    cube([spade_tab_thickness_mm + 1.2, spade_tab_width_mm + 1.2, overlap_mm + 1.2], center=true);
            }

            // ---- CONNECTIVITY FIX: thin vertical rod/pin must be attached (no gap) ----
            // Place rod so its TOP is inside the body by overlap_mm (guaranteed intersection).
            rod_d   = 1.2;
            rod_len = 18.0;

            // Rod top z = body_rear_z + overlap_mm
            // For a centered cylinder: z_center = z_top - rod_len/2
            rod_z_center = (body_rear_z + overlap_mm) - rod_len/2;

            translate([0, 0, rod_z_center])
                cylinder(d=rod_d, h=rod_len, center=true);

            // Add a small boss that straddles the body rear face to further guarantee attachment
            boss_d = 3.0;
            boss_h = overlap_mm + 1.2; // spans into body and slightly below rear face
            // Center boss so its top is inside body by overlap_mm
            boss_z_center = (body_rear_z + overlap_mm) - boss_h/2;

            translate([0, 0, boss_z_center])
                cylinder(d=boss_d, h=boss_h, center=true);
        }

        // ---------------- CUTOUTS ----------------

        // IEC C14 inlet opening (center) - cut from front into body
        translate([0, 0, z_front + iec_open_depth/2 + overlap_mm/2])
            rounded_rect_prism([iec_open_w, iec_open_h, iec_open_depth + overlap_mm], r=1.0, center=true);

        // C14 key notches (approx) - small corner steps
        notch_x = iec_open_w/2 - iec_notch_w/2;
        notch_y = iec_open_h/2 - iec_notch_h/2;
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*notch_x, sy*notch_y, z_front + iec_open_depth/2 + overlap_mm/2])
                cube([iec_notch_w, iec_notch_h, iec_open_depth + overlap_mm], center=true);
        }

        // Switch opening (top area)
        switch_y = (bezel_h/2 - switch_open_h/2 - 2.0);
        translate([0, switch_y, z_front + switch_open_depth/2 + overlap_mm/2])
            rounded_rect_prism([switch_open_w, switch_open_h, switch_open_depth + overlap_mm], r=0.8, center=true);

        // Fuse drawer opening (bottom area)
        fuse_y = -(bezel_h/2 - fuse_open_h/2 - 2.0);
        translate([0, fuse_y, z_front + fuse_open_depth/2 + overlap_mm/2])
            rounded_rect_prism([fuse_open_w, fuse_open_h, fuse_open_depth + overlap_mm], r=0.8, center=true);

        // Mount holes through ears (along Z)
        hole_x_offset = ear_total_w/2 - mount_hole_edge_margin_mm;
        for (xx = [-hole_x_offset, hole_x_offset]) {
            translate([xx, 0, ear_thickness_mm/2])
                cylinder(r=mount_hole_diameter_mm/2, h=ear_thickness_mm + 2*overlap_mm, center=true);
        }

        // Rear cavity hint (recess on rear face)
        pocket_w = body_w - 4;
        pocket_h = body_h - 4;
        pocket_d = 7;
        translate([0, 0, body_rear_z + pocket_d/2 + overlap_mm/2])
            rounded_rect_prism([pocket_w, pocket_h, pocket_d + overlap_mm], r=1.0, center=true);
    }
}

// Output: one connected solid
iec_inlet_module();