$fn = 72;

// IEC fused inlet module (JR-101-1F style, approximate)
// Overall FRONT FACE: 36.0mm (X) x 27.0mm (Y)
// Front face outer surface at Z=0, rear extends to -Z.
// One connected solid (all added features overlap into main body).

module rounded_rect_2d(w, h, r) {
    r2 = min(r, min(w, h)/2);
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(w/2 - r2), sy*(h/2 - r2)]) circle(r=r2);
    }
}

module iec_fused_power_inlet() {
    // --- Target overall face size ---
    face_w = 36.0;
    face_h = 27.0;

    // --- Main depths ---
    flange_t = 2.6;     // front flange thickness
    body_d   = 26.0;    // rear body depth (behind flange)

    // --- Rear body size (typical snap-in module body) ---
    body_w = 30.5;
    body_h = 22.5;

    // --- IEC C14 inlet opening (front) ---
    inlet_w = 27.0;
    inlet_h = 19.0;
    inlet_r = 2.2;
    inlet_cut_d = flange_t + 10.0; // cut through flange and into body

    // --- Fuse drawer feature (front, above inlet) ---
    fuse_w = 20.5;
    fuse_h = 8.6;
    fuse_r = 1.2;
    fuse_depth = 1.8;   // recess depth into front face

    // Fuse drawer "lip" (raised frame) around recess
    fuse_lip_t = 0.9;
    fuse_lip_wall = 1.2;

    // --- Rocker switch feature (front, below inlet) ---
    sw_w = 19.0;
    sw_h = 12.0;
    sw_r = 1.6;
    sw_depth = 1.6;

    // Switch bezel (raised frame)
    sw_lip_t = 0.9;
    sw_lip_wall = 1.2;

    // --- Rear terminal blades (3) ---
    blade_w = 6.3;
    blade_t = 0.8;
    blade_l = 10.0;
    blade_spacing = 7.5; // center-to-center

    // --- Rear strain relief / housing bump ---
    bump_w = 18.0;
    bump_h = 11.0;
    bump_d = 7.0;

    // --- Side snap tabs (simple protrusions) ---
    tab_w = 3.0;
    tab_h = 8.0;
    tab_d = 6.0;

    // Connectivity overlap (use 1-2mm to guarantee fusion)
    overlap = 1.2;

    // --- Derived Z positions (formulas, no arbitrary floats) ---
    // Flange occupies Z in [-flange_t, 0]
    // Body occupies Z in [-(flange_t+body_d), -flange_t]
    body_front_z = -flange_t;
    body_back_z  = -(flange_t + body_d);

    // Place blades so they overlap into rear body by 'overlap'
    blade_z_center = body_back_z + (blade_l/2) - overlap;

    // Place bump so it overlaps into rear body by 'overlap'
    bump_z_center = body_back_z + (bump_d/2) - overlap;

    // Feature vertical layout on face (Y axis)
    // Fuse above inlet, switch below inlet
    inlet_y = 0;
    fuse_y  = (face_h/2) - (fuse_h/2 + 2.2);
    sw_y    = -(face_h/2) + (sw_h/2 + 2.2);

    // Raised lips sit on the front face and overlap slightly into flange
    lip_embed = 0.25;

    // --- INTERNAL ORANGE INSERTS/BLOCKS (structural fix) ---
    // These were visually floating/disconnected in the provided views.
    // Fix: create a single continuous internal "carrier" that:
    //  1) overlaps into the main body (Z overlap)
    //  2) overlaps into the flange (Z overlap)
    //  3) bridges the two blocks so they are one connected solid
    //
    // Keep the look: two rounded rectangles (upper/lower) with a small bridge.
    insert_w = 24.0;
    insert_h = 9.5;
    insert_r = 1.6;

    // Place inserts inside the face opening area (same Y layout as fuse/switch)
    insert_upper_y = fuse_y;
    insert_lower_y = sw_y;

    // Thickness and Z placement: ensure intersection with flange/body.
    // Make the insert extend slightly behind the flange into the body.
    insert_t = flange_t + overlap;                 // guarantees it intersects flange volume
    insert_z_center = -flange_t + insert_t/2 - overlap; // pushes it into body by ~overlap

    // Bridge between the two inserts so they are not separated.
    // Use hull between two small rounded pads to create a continuous web.
    bridge_w = insert_w * 0.55;
    bridge_h = 3.2;
    bridge_r = 1.2;

    difference() {
        union() {
            // --- Front flange (exact 36x27) ---
            translate([0, 0, -flange_t/2])
                linear_extrude(height=flange_t, center=true)
                    rounded_rect_2d(face_w, face_h, 1.6);

            // --- Rear body (connected to flange) ---
            translate([0, 0, -(flange_t + body_d/2)])
                linear_extrude(height=body_d, center=true)
                    rounded_rect_2d(body_w, body_h, 1.8);

            // --- Rear bump (connected to rear body) ---
            translate([0, 0, bump_z_center])
                linear_extrude(height=bump_d, center=true)
                    rounded_rect_2d(bump_w, bump_h, 1.4);

            // --- Side snap tabs (connected to body sides) ---
            // Tabs centered in Z within rear body, protruding outward in X
            tab_z_center = -(flange_t + body_d/2);
            for (sx = [-1, 1]) {
                translate([sx*(body_w/2 + tab_w/2 - overlap), 0, tab_z_center])
                    cube([tab_w, tab_h, tab_d], center=true);
            }

            // --- Terminal blades (connected to rear body) ---
            for (i = [-1, 0, 1]) {
                translate([i*blade_spacing, 0, blade_z_center])
                    cube([blade_w, blade_t, blade_l], center=true);
            }

            // --- INTERNAL INSERTS (now attached + fused + bridged) ---
            // Upper insert
            translate([0, insert_upper_y, insert_z_center])
                linear_extrude(height=insert_t, center=true)
                    rounded_rect_2d(insert_w, insert_h, insert_r);

            // Lower insert
            translate([0, insert_lower_y, insert_z_center])
                linear_extrude(height=insert_t, center=true)
                    rounded_rect_2d(insert_w, insert_h, insert_r);

            // Bridge web between upper and lower inserts (single continuous solid)
            // Positioned midway in Y, same Z, and overlaps both inserts.
            bridge_y = (insert_upper_y + insert_lower_y)/2;
            translate([0, bridge_y, insert_z_center])
                linear_extrude(height=insert_t, center=true)
                    hull() {
                        translate([0, (insert_upper_y - bridge_y) - (bridge_h/2 - overlap/2), 0])
                            rounded_rect_2d(bridge_w, bridge_h, bridge_r);
                        translate([0, (insert_lower_y - bridge_y) + (bridge_h/2 - overlap/2), 0])
                            rounded_rect_2d(bridge_w, bridge_h, bridge_r);
                    }

            // --- Fuse drawer raised lip (front) ---
            translate([0, fuse_y, -(fuse_lip_t/2) + lip_embed])
                difference() {
                    linear_extrude(height=fuse_lip_t, center=true)
                        rounded_rect_2d(fuse_w + 2*fuse_lip_wall, fuse_h + 2*fuse_lip_wall, fuse_r + 0.6);
                    linear_extrude(height=fuse_lip_t + 0.2, center=true)
                        rounded_rect_2d(fuse_w, fuse_h, fuse_r);
                }

            // --- Switch raised lip (front) ---
            translate([0, sw_y, -(sw_lip_t/2) + lip_embed])
                difference() {
                    linear_extrude(height=sw_lip_t, center=true)
                        rounded_rect_2d(sw_w + 2*sw_lip_wall, sw_h + 2*sw_lip_wall, sw_r + 0.6);
                    linear_extrude(height=sw_lip_t + 0.2, center=true)
                        rounded_rect_2d(sw_w, sw_h, sw_r);
                }
        }

        // --- IEC C14 inlet opening (through flange and into body) ---
        translate([0, inlet_y, -(inlet_cut_d/2)])
            linear_extrude(height=inlet_cut_d, center=true)
                rounded_rect_2d(inlet_w, inlet_h, inlet_r);

        // --- Fuse drawer recess (front face) ---
        translate([0, fuse_y, -(fuse_depth/2)])
            linear_extrude(height=fuse_depth + 0.02, center=true)
                rounded_rect_2d(fuse_w, fuse_h, fuse_r);

        // Fuse finger-pull notch (small cut under fuse recess)
        notch_w = 10.5;
        notch_h = 2.4;
        notch_d = 1.6;
        notch_y = fuse_y - fuse_h/2 - notch_h/2 + 0.2;
        translate([0, notch_y, -(notch_d/2)])
            cube([notch_w, notch_h, notch_d + 0.02], center=true);

        // --- Switch recess (front face) ---
        translate([0, sw_y, -(sw_depth/2)])
            linear_extrude(height=sw_depth + 0.02, center=true)
                rounded_rect_2d(sw_w, sw_h, sw_r);

        // Small rocker "split line" groove (visual cue)
        groove_w = sw_w - 2.0;
        groove_h = 0.9;
        groove_d = 0.8;
        translate([0, sw_y, -(groove_d/2)])
            cube([groove_w, groove_h, groove_d + 0.02], center=true);
    }
}

iec_fused_power_inlet();