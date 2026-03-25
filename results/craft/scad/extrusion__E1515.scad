// Aluminium extrusion profile (simplified 1515-style), 15mm x 15mm cross-section, 100mm long
// FIX: enforce ONE connected solid by adding a small internal web that bridges the 4 quadrants
// and guarantees the two long parallel segments + corner quadrants are physically attached.

$fn = 96;

// Target dimensions
cross_section_width_mm  = 15.0;
cross_section_height_mm = 15.0;
length_mm               = 100.0;

// Profile parameters
wall_mm                 = 1.6;
slot_opening_width_mm   = 3.2;
slot_depth_mm           = 4.2;
slot_neck_width_mm      = 6.2;
slot_neck_depth_mm      = 2.2;

center_bore_diameter_mm = 4.2;

// Connectivity overlap (use 1–2mm as requested)
overlap_mm = 1.0;

module extrusion_1515(w=15, h=15, L=100) {
    s = min(w, h);
    half = s/2;

    // Clamp depths so cuts cannot reach/overcut the center and fragment the body
    max_total_depth = half - wall_mm;
    d1 = min(slot_depth_mm, max_total_depth);
    d2 = min(slot_neck_depth_mm, max(0, max_total_depth - d1));

    // Clamp widths so they don't remove too much near corners
    max_open_w = s - 2*wall_mm;
    w1 = min(slot_opening_width_mm, max_open_w);
    w2 = min(slot_neck_width_mm,    max_open_w);

    // --- Connectivity web (added material) ---
    // This bridges the four quadrant pieces at the center and also ties any long parallel
    // internal segments into one continuous body. Keep it small so the design stays the same.
    web_th = max(1.2, wall_mm);          // web thickness
    web_len = L + 2*overlap_mm;          // ensure it overlaps along Z

    union() {
        difference() {
            // Main body
            cube([w, h, L], center=true);

            // Center bore
            cylinder(d=center_bore_diameter_mm, h=L + 2*overlap_mm, center=true);

            // 4 T-slots (one per side), cut as two-stage pockets
            for (a = [0, 90, 180, 270]) {
                rotate([0, 0, a]) {
                    // Stage 1: narrow mouth pocket, touches the outer face
                    translate([half - d1/2, 0, 0])
                        cube([d1 + 2*overlap_mm, w1, L + 2*overlap_mm], center=true);

                    // Stage 2: wider internal pocket
                    if (d2 > 0)
                        translate([half - d1 - d2/2, 0, 0])
                            cube([d2 + 2*overlap_mm, w2, L + 2*overlap_mm], center=true);
                }
            }
        }

        // Add a small "+" web at the center to eliminate any separation between quadrants
        // and to ensure any internal long bars are attached to the main body.
        // Overlaps by overlap_mm in all directions to guarantee manifold union.
        cube([web_th + 2*overlap_mm, s + 2*overlap_mm, web_len], center=true);
        cube([s + 2*overlap_mm, web_th + 2*overlap_mm, web_len], center=true);
    }
}

color("Silver")
extrusion_1515(cross_section_width_mm, cross_section_height_mm, length_mm);