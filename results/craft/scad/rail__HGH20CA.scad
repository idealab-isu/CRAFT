$fn = 96;

// Target overall dimensions
width_mm  = 20.0;   // X
height_mm = 17.5;   // Z
length_mm = 100.0;  // Y

// Mounting holes (typical linear rail)
mount_hole_diameter_mm = 4.5;          // through
mount_hole_counterbore_diameter_mm = 8.0;
mount_hole_counterbore_depth_mm = 4.0;
mount_hole_pitch_mm = 25.0;
mount_hole_end_offset_mm = 12.5;
mount_hole_count = 4;

// Profile details (approximate rail features)
top_flat_w_mm = 12.0;
top_step_drop_mm = 1.2;
side_undercut_depth_mm = 1.6;
side_undercut_height_mm = 6.0;
side_undercut_z_center_mm = 8.0;

bottom_relief_depth_mm = 0.8;
bottom_relief_w_mm = 10.0;

edge_chamfer_mm = 0.6;
overlap_mm = 0.25;
hole_extra_depth_mm = 2.0;

// Structural connectivity overlap (1–2mm as required)
attach_overlap_mm = 1.2;

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

module rail_profile_2d() {
    // 2D cross-section in X-Z plane, extruded along Y
    w = width_mm;
    h = height_mm;

    ch = clamp(edge_chamfer_mm, 0, min(w,h)/4);

    top_flat_w = clamp(top_flat_w_mm, 0.1, w - 2*ch);
    top_step_drop = clamp(top_step_drop_mm, 0, h - 0.1);

    // Shoulder width at the step level
    shoulder_w = clamp(top_flat_w + 2*2.0, top_flat_w, w - 2*ch);

    // Side undercut parameters
    uc_d = clamp(side_undercut_depth_mm, 0, w/2 - 0.5);
    uc_h = clamp(side_undercut_height_mm, 0.1, h - 0.5);
    uc_zc = clamp(side_undercut_z_center_mm, uc_h/2 + 0.2, h - uc_h/2 - 0.2);

    // Bottom relief
    br_d = clamp(bottom_relief_depth_mm, 0, h/2);
    br_w = clamp(bottom_relief_w_mm, 0.1, w - 2*ch);

    // Outer polygon (simple chamfers + top step)
    outer = [
        [-w/2 + ch, 0],
        [ w/2 - ch, 0],
        [ w/2, ch],
        [ w/2, h - ch],
        [ w/2 - ch, h],

        // top step geometry
        [ w/2 - (w - top_flat_w)/2, h],                 // right edge of top flat
        [ w/2 - (w - shoulder_w)/2, h - top_step_drop],  // right shoulder at step
        [-w/2 + (w - shoulder_w)/2, h - top_step_drop],  // left shoulder at step
        [-w/2 + (w - top_flat_w)/2, h],                  // left edge of top flat

        [-w/2 + ch, h],
        [-w/2, h - ch],
        [-w/2, ch]
    ];

    difference() {
        polygon(points=outer);

        // Side undercuts (raceway-like grooves), symmetric
        for (sx = [-1, 1]) {
            translate([sx*(w/2 - uc_d/2), uc_zc])
                square([uc_d + overlap_mm, uc_h + overlap_mm], center=true);
        }

        // Bottom relief slot
        translate([0, br_d/2])
            square([br_w + overlap_mm, br_d + overlap_mm], center=true);
    }
}

module rail_body_core() {
    // Extrude along Y (length). Keep centered for easy hole placement.
    linear_extrude(height=length_mm, center=true, convexity=10)
        rail_profile_2d();
}

// Bottom rectangular feature: MUST be attached (overlap 1–2mm into rail body).
module bottom_rect_feature() {
    feat_w = clamp(bottom_relief_w_mm * 0.55, 4.0, width_mm - 2.0); // X
    feat_h = 1.6;                                                   // Z thickness
    feat_l = length_mm;                                             // Y

    // Rail body (core) spans Z: [-height_mm/2 .. +height_mm/2] because extrusion is centered.
    // Attach feature below the rail, with its top penetrating into the rail by attach_overlap_mm.
    // Feature Z extents: [z0 .. z0+feat_h], where z0 = -height_mm/2 - feat_h + attach_overlap_mm
    z0 = -height_mm/2 - feat_h + attach_overlap_mm;
    translate([0, 0, z0 + feat_h/2])
        cube([feat_w, feat_l, feat_h], center=true);
}

module rail_body() {
    // Union all solids so there are no floating/disconnected parts.
    union() {
        rail_body_core();
        bottom_rect_feature();
    }
}

module mounting_holes() {
    // Holes oriented along Z (down from top face).
    for (i = [0:mount_hole_count-1]) {
        y = -length_mm/2 + mount_hole_end_offset_mm + i*mount_hole_pitch_mm;

        // Through hole: start slightly above top, cut down past bottom
        translate([0, y, height_mm/2 + overlap_mm])
            cylinder(h=height_mm + hole_extra_depth_mm + 2*overlap_mm,
                     r=mount_hole_diameter_mm/2,
                     center=false);

        // Counterbore: starts at top surface and goes down
        translate([0, y, height_mm/2 - mount_hole_counterbore_depth_mm - overlap_mm])
            cylinder(h=mount_hole_counterbore_depth_mm + 2*overlap_mm,
                     r=mount_hole_counterbore_diameter_mm/2,
                     center=false);
    }
}

module rail() {
    difference() {
        rail_body();
        mounting_holes();
    }
}

rail();