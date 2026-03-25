$fn = 128;

// Parameters (requested bearing size)
bore_diameter_mm  = 8.0;
outer_diameter_mm = 15.0;
length_mm         = 24.0;

// Simple LM8UU-style exterior details (subtle, still within OD)
chamfer_mm        = 0.6;   // end chamfer height
groove_w_mm       = 1.2;   // groove width
groove_depth_mm   = 0.35;  // groove radial depth (kept small)
groove_offset_mm  = 2.0;   // distance from each end to groove center
overlap_mm        = 0.2;   // boolean robustness

module linear_bearing_LM8UU_like() {
    difference() {
        // Outer body with small end chamfers
        union() {
            // Main cylinder (slightly shortened to make room for chamfers)
            cylinder(h = length_mm - 2*chamfer_mm, r = outer_diameter_mm/2, center = true);

            // End chamfers (frustums)
            for (z = [-1, 1]) {
                translate([0, 0, z*(length_mm/2 - chamfer_mm/2)])
                    cylinder(
                        h = chamfer_mm,
                        r1 = outer_diameter_mm/2,
                        r2 = outer_diameter_mm/2 - chamfer_mm,
                        center = true
                    );
            }
        }

        // Bore
        cylinder(h = length_mm + 2*overlap_mm, r = bore_diameter_mm/2, center = true);

        // Two shallow exterior grooves near ends (LM8UU-like)
        for (z = [-1, 1]) {
            translate([0, 0, z*(length_mm/2 - groove_offset_mm)])
                cylinder(
                    h = groove_w_mm,
                    r = outer_diameter_mm/2 - groove_depth_mm,
                    center = true
                );
        }
    }
}

// One connected solid: the bearing itself (no protruding shaft/handle)
linear_bearing_LM8UU_like();