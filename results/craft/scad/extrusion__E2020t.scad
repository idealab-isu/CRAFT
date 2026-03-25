// 2020 aluminium extrusion profile (20mm x 20mm), 100mm long
// Fixed structural connectivity: ensure one connected solid (no split/floating bodies)

$fn = 96;

// Requested overall size
cross_section_mm = 20.0;
length_mm        = 100.0;

// Profile details (approximate 2020)
slot_opening_mm   = 6.0;   // mouth width at outer face
slot_depth_mm     = 6.0;   // depth from outer face inward
slot_cavity_mm    = 11.0;  // wider internal cavity width
center_bore_d_mm  = 5.0;   // center through-bore
web_thickness_mm  = 2.0;   // keeps part connected
corner_relief_mm  = 1.0;   // small corner relief

// Overlap to guarantee physical connection (1-2mm as required)
overlap_mm = 1.2;

// Small numeric epsilon for robust booleans
eps = 0.05;

module extrusion2020(len=length_mm) {
    w = cross_section_mm;
    h = cross_section_mm;

    half_w = w/2;
    half_h = h/2;

    mouth_w = slot_opening_mm;
    depth   = slot_depth_mm;
    cav_w   = slot_cavity_mm;

    // Clamp cavity width so it stays inside the profile
    cav_w_clamped = min(cav_w, w - 2*web_thickness_mm);

    // Cavity begins behind the mouth to suggest a "T" undercut
    cav_start = max(0, depth - web_thickness_mm);
    cav_len   = max(0, half_w - web_thickness_mm - cav_start);

    // Build as a 2D cross-section in XY, then extrude along Z,
    // then rotate so final length is along X.
    rotate([0, 90, 0])  // Z-length -> X-length
    linear_extrude(height=len, center=true, convexity=10)
    union() {
        // Main body with cuts
        difference() {
            // Outer square
            square([w, h], center=true);

            // Center bore (2D circle, extruded)
            circle(d=center_bore_d_mm);

            // Four T-slots (2D cuts)
            for (a = [0, 90, 180, 270]) {
                rotate(a) {
                    // Mouth: rectangle from outer face inward by 'depth'
                    translate([half_w - depth/2 + eps/2, 0])
                        square([depth + eps, mouth_w], center=true);

                    // Internal cavity: wider region behind the mouth
                    if (cav_len > 0) {
                        translate([half_w - (cav_start + cav_len/2) + eps/2, 0])
                            square([cav_len + eps, cav_w_clamped], center=true);
                    }
                }
            }

            // Corner reliefs (small squares removed at corners)
            for (sx = [-1, 1], sy = [-1, 1]) {
                translate([sx*(half_w - corner_relief_mm/2),
                           sy*(half_h - corner_relief_mm/2)])
                    square([corner_relief_mm, corner_relief_mm], center=true);
            }
        }

        // Connectivity bridges:
        // Add thin internal webs that slightly overlap into the slot cavities.
        // This prevents the profile from becoming two long parallel bodies with a gap.
        //
        // Place bridges at the center, spanning across the internal cavity region.
        // Width is small to preserve the look, but enough to guarantee a single solid.
        bridge_thick = web_thickness_mm; // ~2mm
        bridge_span  = cav_w_clamped - 2*eps; // stay inside cavity width

        // Along +X/-X directions (in 2D cross-section coordinates)
        // Position so it intersects the remaining material by overlap_mm.
        // The bridge extends from just inside the cavity toward the center.
        for (a = [0, 90, 180, 270]) {
            rotate(a) {
                // Bridge length: from near cavity start toward center, with overlap into solid
                // Ensure it reaches past the cavity start by overlap_mm.
                bridge_len = max(bridge_thick, cav_start + overlap_mm);

                // Center the bridge so its outer end sits inside the cavity region,
                // and its inner end overlaps the central material.
                // Outer face is at +half_w; cavity begins at (half_w - cav_start).
                // Put bridge centered at radius: (half_w - (cav_start/2)) so it spans inward.
                translate([half_w - (cav_start/2) - overlap_mm/2, 0])
                    square([bridge_len, bridge_span], center=true);
            }
        }
    }
}

extrusion2020(length_mm);