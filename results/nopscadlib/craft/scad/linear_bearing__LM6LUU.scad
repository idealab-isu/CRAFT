// Long linear bearing (single connected solid)
// Target: 6.0mm bore, 12.0mm outer diameter, 35.0mm length

$fn = 128;

// Parameters
bore_diameter_mm  = 6.0;   // bore
outer_diameter_mm = 12.0;  // OD
length_mm         = 35.0;  // overall length

// Optional cosmetic features (kept subtle and fully connected)
groove_enabled    = 1;     // 0/1
groove_length_mm  = 2.0;
groove_depth_mm   = 0.4;
groove_spacing_mm = 20.0;

seal_lips_enabled             = 1;   // 0/1
seal_lip_length_mm            = 2.0;
seal_lip_radial_thickness_mm  = 0.8;
seal_clearance_mm             = 0.1;

overlap_mm = 0.2; // small overlap for robust CSG

module linear_bearing() {
    bore_r  = bore_diameter_mm/2;
    outer_r = outer_diameter_mm/2;

    // Main sleeve with through-bore
    difference() {
        union() {
            // Outer body
            cylinder(r=outer_r, h=length_mm, center=true);

            // End seal lips (added material, still one connected solid)
            if (seal_lips_enabled) {
                for (z = [-1, 1]) {
                    translate([0, 0, z*(length_mm/2 - seal_lip_length_mm/2)])
                        cylinder(r=bore_r + seal_clearance_mm + seal_lip_radial_thickness_mm,
                                 h=seal_lip_length_mm + overlap_mm,
                                 center=true);
                }
            }
        }

        // Through bore (cuts everything)
        cylinder(r=bore_r, h=length_mm + 2*seal_lip_length_mm + 4*overlap_mm, center=true);

        // Optional shallow outer grooves (cosmetic)
        if (groove_enabled) {
            for (z = [-1, 1]) {
                translate([0, 0, z*(groove_spacing_mm/2)])
                    cylinder(r=outer_r - groove_depth_mm,
                             h=groove_length_mm + 2*overlap_mm,
                             center=true);
            }
        }

        // Clear the seal lip inner diameter (slightly larger than bore)
        if (seal_lips_enabled) {
            for (z = [-1, 1]) {
                translate([0, 0, z*(length_mm/2 - seal_lip_length_mm/2)])
                    cylinder(r=bore_r + seal_clearance_mm,
                             h=seal_lip_length_mm + 4*overlap_mm,
                             center=true);
            }
        }
    }
}

linear_bearing();