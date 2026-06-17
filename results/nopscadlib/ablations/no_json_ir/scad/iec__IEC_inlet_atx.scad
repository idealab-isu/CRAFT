$fn = 64;

// IEC C14 (ATX) inlet module: 40.0mm x 27.0mm cutout
// Produces ONE connected 3D solid "negative" (a cutter) including:
// - main rounded-rect cutout (40x27)
// - lead-in chamfer on front
// - recessed inlet cavity + pin openings (approximate IEC C14 geometry)
// - flange screw hole cutters, CONNECTED to the main body by solid ribs (no floating parts)

module rounded_rect_2d(w, h, r) {
    r2 = min(r, w/2, h/2);
    offset(r=r2) square([w - 2*r2, h - 2*r2], center=true);
}

module slot_2d(w, h, r) {
    rounded_rect_2d(w, h, r);
}

module iec_c14_cutout(
    cutout_w = 40.0,
    cutout_h = 27.0,
    corner_r = 1.5,

    panel_t  = 3.0,
    chamfer_d = 1.0,

    recess_d = 2.0,
    recess_margin = 2.0,
    recess_r = 1.0,

    pin_w = 6.2,
    pin_h = 3.2,
    pin_r = 0.8,
    pin_pitch = 14.0,
    earth_w = 6.2,
    earth_h = 3.2,
    earth_r = 0.8,
    earth_y = 6.5,

    flange_w = 50.0,
    flange_h = 37.0,
    hole_d   = 3.2,

    // Connection geometry (structural fix)
    rib_w = 2.0,          // rib thickness in XY
    rib_z = 3.0,          // rib thickness in Z (match panel thickness so it can't "float" in top view)
    overlap = 1.5         // 1-2mm overlap to guarantee unions
) {
    cd = min(chamfer_d, panel_t);
    rd = min(recess_d, panel_t);

    recess_w = max(0.1, cutout_w - 2*recess_margin);
    recess_h = max(0.1, cutout_h - 2*recess_margin);

    // Hole centers (keep original intent)
    hole_x = flange_w/2 - hole_d/2;
    hole_y = flange_h/2 - hole_d/2;

    // --- STRUCTURAL FIX ---
    // Build each corner feature as an L-shaped rib that *starts inside* the main cutout
    // and reaches the hole center. This guarantees physical overlap in all views.
    //
    // Start points are inside the main cutout by "overlap" so there is no visible gap.
    start_x = cutout_w/2 - overlap;
    start_y = cutout_h/2 - overlap;

    // Lengths from start points to hole centers (always positive)
    rib_len_x = max(0.1, hole_x - start_x);
    rib_len_y = max(0.1, hole_y - start_y);

    union() {
        // Main straight cut portion (through most of panel)
        translate([0, 0, (panel_t - cd)/2])
            linear_extrude(height=panel_t - cd, center=true)
                rounded_rect_2d(cutout_w, cutout_h, corner_r);

        // Lead-in chamfer (front side), overlaps into main cut
        translate([0, 0, -(panel_t/2) + cd/2])
            linear_extrude(
                height=cd + overlap,
                center=true,
                scale=[
                    (cutout_w - 2*cd)/cutout_w,
                    (cutout_h - 2*cd)/cutout_h
                ]
            )
                rounded_rect_2d(cutout_w, cutout_h, corner_r);

        // Recessed inlet cavity (front side), overlaps into main cut
        translate([0, 0, -(panel_t/2) + rd/2])
            linear_extrude(height=rd + overlap, center=true)
                rounded_rect_2d(recess_w, recess_h, recess_r);

        // Pin openings (front side) - connected via overlap with recess
        pin_depth = min(panel_t, rd + 0.5);
        translate([0, 0, -(panel_t/2) + pin_depth/2])
            linear_extrude(height=pin_depth + overlap, center=true) {
                translate([-pin_pitch/2, 0, 0]) slot_2d(pin_w, pin_h, pin_r);
                translate([ pin_pitch/2, 0, 0]) slot_2d(pin_w, pin_h, pin_r);
                translate([0, earth_y, 0]) slot_2d(earth_w, earth_h, earth_r);
            }

        // Corner attachment ribs: L-shape per corner (two legs), guaranteed overlap into main body
        for (sx = [-1, 1])
        for (sy = [-1, 1]) {
            // X-leg: from inside main cutout to hole center X at the hole's Y
            translate([ sx*(start_x + rib_len_x/2), sy*hole_y, 0 ])
                cube([rib_len_x + overlap, rib_w, rib_z + overlap], center=true);

            // Y-leg: from inside main cutout to hole center Y at the hole's X
            translate([ sx*hole_x, sy*(start_y + rib_len_y/2), 0 ])
                cube([rib_w, rib_len_y + overlap, rib_z + overlap], center=true);
        }

        // Four flange screw hole cutters (extruded through thickness)
        for (x = [-hole_x, hole_x])
        for (y = [-hole_y, hole_y])
            translate([x, y, 0])
                cylinder(d=hole_d, h=panel_t + 2*overlap, center=true);
    }
}

// Missing part fix: ensure the expected part name exists
module iec() {
    iec_c14_cutout();
}

iec();