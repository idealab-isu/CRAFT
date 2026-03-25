$fn = 96;

// Parameters (mm)
overall_height_mm = 28.5;                 // total height including positive button
outer_diameter_mm = 10.3;                 // main can diameter
positive_terminal_diameter_mm = 4.5;      // button diameter
positive_terminal_height_mm = 1.0;        // button height above top face
negative_terminal_recess_mm = 0.6;        // shallow recess on negative end (0 = flat)
edge_chamfer_mm = 0.2;                    // small edge bevel (visual)
connect_overlap_mm = 0.2;                 // overlap to guarantee watertight union

module battery() {
    outer_r = outer_diameter_mm/2;
    pos_r   = positive_terminal_diameter_mm/2;

    // Heights
    body_h = overall_height_mm - positive_terminal_height_mm; // main can height
    pos_h  = positive_terminal_height_mm;

    // Z references (centered model)
    z_body_center = 0;
    z_top_face    = z_body_center + body_h/2;
    z_bot_face    = z_body_center - body_h/2;

    // Positive button placement (connected with slight overlap into body)
    z_pos_center = z_top_face + pos_h/2 - connect_overlap_mm/2;

    // Ensure subtractive features never fully remove the solid
    safe_chamfer = min(edge_chamfer_mm, max(0, body_h/2 - 0.01));
    safe_recess  = min(negative_terminal_recess_mm, max(0, body_h/2 - safe_chamfer - 0.01));

    difference() {
        union() {
            // Main can
            cylinder(r=outer_r, h=body_h, center=true);

            // Positive terminal button
            translate([0, 0, z_pos_center])
                cylinder(r=pos_r, h=pos_h + connect_overlap_mm, center=true);
        }

        // Negative terminal recess (subtracted from bottom face)
        if (safe_recess > 0) {
            recess_r = max(0.01, outer_r - safe_chamfer);
            z_recess_center = z_bot_face + safe_recess/2;
            translate([0, 0, z_recess_center])
                cylinder(r=recess_r, h=safe_recess, center=true);
        }

        // Small top edge chamfer (subtractive ring)
        if (safe_chamfer > 0) {
            chamfer_h = safe_chamfer;
            z_chamfer_center = z_top_face - chamfer_h/2;
            translate([0, 0, z_chamfer_center])
                cylinder(r1=outer_r, r2=max(0.01, outer_r - safe_chamfer), h=chamfer_h, center=true);
        }

        // Small bottom edge chamfer (subtractive ring)
        if (safe_chamfer > 0) {
            chamfer_h = safe_chamfer;
            z_chamfer_center = z_bot_face + chamfer_h/2;
            translate([0, 0, z_chamfer_center])
                cylinder(r1=max(0.01, outer_r - safe_chamfer), r2=outer_r, h=chamfer_h, center=true);
        }
    }
}

battery();