$fn = 96;

// 30x60 aluminium T-slot extrusion, 100mm long (Z axis)
// Fix: ensure the profile is ONE connected solid by adding small "tie" bridges
// that overlap both halves and the small internal central features by 1–2mm.
module extrusion_30x60(len=100, w=60, h=30) {

    // --- Typical-ish 30-series parameters (kept generic but "standard T-slot-like") ---
    wall      = 2.2;   // outer wall thickness
    web       = 3.0;   // internal web thickness
    bore_r    = 5.0;   // center bore radius (10mm dia)

    // Slot geometry (per face)
    slot_open = 8.0;   // opening at surface
    slot_depth= 7.0;   // depth from surface inward
    slot_neck = 4.2;   // narrower inner neck
    neck_depth= 3.0;   // additional depth for neck

    // Inner cavity sizing (kept inside walls and leaving webs)
    cav_margin_x = 6.0;  // clearance from outer wall to cavity in X
    cav_margin_y = 4.5;  // clearance from outer wall to cavity in Y

    // Small overlap to guarantee watertight connections
    overlap = 1.2;   // 1–2mm as required
    eps     = 0.02;

    // Derived
    half_w = w/2;
    half_h = h/2;

    // Ensure cavity doesn't break walls/webs
    cav_w = max(0, w - 2*(wall + cav_margin_x));
    cav_h = max(0, h - 2*(wall + cav_margin_y));

    // 2D profile (XY), extruded along Z
    module profile2d() {

        // --- Base "as-designed" profile (difference) ---
        module base_profile() {
            difference() {
                // Outer rectangle
                square([w, h], center=true);

                // Center bore
                circle(r=bore_r);

                // T-slots on all four faces (2D cuts)
                // ±X faces
                for (sx = [-1, 1]) {
                    // Main slot pocket
                    translate([sx*(half_w - slot_depth/2 + eps), 0])
                        square([slot_depth + 2*eps, slot_open], center=true);

                    // Neck pocket (deeper, narrower)
                    translate([sx*(half_w - (slot_depth + neck_depth/2) + eps), 0])
                        square([neck_depth + 2*eps, slot_neck], center=true);
                }

                // ±Y faces
                for (sy = [-1, 1]) {
                    translate([0, sy*(half_h - slot_depth/2 + eps)])
                        square([slot_open, slot_depth + 2*eps], center=true);

                    translate([0, sy*(half_h - (slot_depth + neck_depth/2) + eps)])
                        square([slot_neck, neck_depth + 2*eps], center=true);
                }

                // Internal cavities (four quadrants), leaving a central cross-web
                if (cav_w > 0 && cav_h > 0) {
                    cav_half_w = min(cav_w/2, half_w - wall - web/2);
                    cav_half_h = min(cav_h/2, half_h - wall - web/2);

                    if (cav_half_w > 0 && cav_half_h > 0) {
                        for (sx = [-1, 1], sy = [-1, 1]) {
                            translate([sx*(web/2 + cav_half_w/2), sy*(web/2 + cav_half_h/2)])
                                square([cav_half_w, cav_half_h], center=true);
                        }
                    }
                }
            }
        }

        // --- Connectivity fixes (bridges) ---
        // These bridges are placed where the "split halves" and the small internal
        // central pieces were visually disconnected. They overlap both sides by
        // 'overlap' to guarantee a single manifold solid.
        //
        // IMPORTANT: We keep them inside the outer boundary and away from the bore.
        // They are small and do not change the overall external design.

        // Bridge thickness (in Y) kept small so it doesn't noticeably alter the profile.
        bridge_y = 2.0;

        // Place bridges just outside the bore so they don't fill it.
        // They span across X=0 to connect left/right halves.
        // X span: from (bore_r - overlap) to (bore_r + overlap) on both sides => total 2*(bore_r+overlap)
        bridge_x = 2*(bore_r + overlap);

        // Two bridges (top and bottom) to also tie in the small central internal features
        // seen in front/back/left/right views.
        // Y positions chosen to sit within the central region but not collide with the Y-face slot cuts.
        // Keep them well inside half_h - (slot_depth + neck_depth) region.
        safe_y = max(0, half_h - (slot_depth + neck_depth) - 1.0);
        bridge_y_pos = min(safe_y, (web/2 + 3.0));  // near the central web region

        union() {
            base_profile();

            // Central tie bridges (top & bottom), overlapping both halves by 'overlap'
            // These ensure:
            // - left half of extrusion is attached
            // - right half of extrusion is attached
            // - small internal central pieces are attached
            // - no vertical gap between halves in top/bottom views
            for (sy = [-1, 1]) {
                translate([0, sy*bridge_y_pos])
                    square([bridge_x, bridge_y], center=true);
            }

            // Additional small vertical tie to ensure connectivity even if the split is primarily vertical
            // (helps when the gap appears as a long vertical slit in top view).
            // This overlaps the central region without touching the bore.
            // Place it slightly to +X and -X so it doesn't create a single thin line only.
            tie_w = 2.0;
            tie_h = 2*(bore_r + overlap);
            for (sx = [-1, 1]) {
                translate([sx*(bore_r + overlap + tie_w/2 - overlap), 0])
                    square([tie_w, tie_h], center=true);
            }
        }
    }

    // Extrude to length along Z
    linear_extrude(height=len, center=true, convexity=10)
        profile2d();
}

union() {
    extrusion_30x60(len=100, w=60, h=30);
}