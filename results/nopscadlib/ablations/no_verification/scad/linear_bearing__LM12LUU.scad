$fn = 128;

// Target bearing dimensions (mm)
bore_diameter_mm  = 12.0;
outer_diameter_mm = 21.0;
length_mm         = 57.0;

// Derived
bore_r  = bore_diameter_mm/2;
outer_r = outer_diameter_mm/2;

// Small overlap to ensure watertight boolean ops
overlap = 0.2;

// Optional shallow outer grooves (typical LMxxUU style)
groove_count      = 2;     // 0, 1, or 2
groove_width_mm   = 2.0;
groove_depth_mm   = 0.6;
groove_offset_mm  = 18.0;  // distance from center to groove center along length

module long_linear_bearing() {
    difference() {
        // Outer body
        cylinder(r=outer_r, h=length_mm, center=true);

        // Through bore
        cylinder(r=bore_r, h=length_mm + 2*overlap, center=true);

        // Outer grooves (subtractive), placed by formulas from dimensions
        if (groove_count >= 1) {
            for (zpos = (groove_count == 1) ? [0] : [-groove_offset_mm, groove_offset_mm]) {
                translate([0, 0, zpos])
                    difference() {
                        cylinder(r=outer_r + overlap, h=groove_width_mm, center=true);
                        cylinder(r=outer_r - groove_depth_mm, h=groove_width_mm + 2*overlap, center=true);
                    }
            }
        }
    }
}

// One connected solid: just the bearing (no side pins/screws)
long_linear_bearing();