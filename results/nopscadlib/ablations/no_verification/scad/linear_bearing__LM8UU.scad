// Linear bearing (LM8UU-like) — 8mm bore, 15mm OD, 24mm length
// Single connected solid with a true through-bore and shallow outer grooves.

$fn = 128;

// Parameters
bore_diameter_mm  = 8.0;
outer_diameter_mm = 15.0;
length_mm         = 24.0;

// Groove styling (shallow circumferential grooves on OD)
groove_depth_mm   = 0.35;   // radial depth into OD
groove_width_mm   = 1.6;    // axial width
groove_inset_mm   = 3.0;    // distance from each end to groove center

// Small overlap for robust CSG
overlap_mm = 0.2;

module linear_bearing_8x15x24() {
    bore_r  = bore_diameter_mm/2;
    outer_r = outer_diameter_mm/2;

    // Ensure groove placement stays within the part
    groove_center_from_mid = max(0, length_mm/2 - groove_inset_mm);

    difference() {
        // Outer body
        cylinder(r=outer_r, h=length_mm, center=true);

        // Through bore (slightly longer to guarantee a clean cut)
        cylinder(r=bore_r, h=length_mm + 2*overlap_mm, center=true);

        // Two shallow OD grooves: remove only a thin ring at the OD
        for (z = [-groove_center_from_mid, groove_center_from_mid]) {
            translate([0, 0, z])
                difference() {
                    // Outer ring volume to remove (same OD as body)
                    cylinder(r=outer_r + overlap_mm,
                             h=groove_width_mm + 2*overlap_mm,
                             center=true);
                    // Keep everything inside this radius (so only the outer skin is removed)
                    cylinder(r=outer_r - groove_depth_mm,
                             h=groove_width_mm + 4*overlap_mm,
                             center=true);
                }
        }
    }
}

linear_bearing_8x15x24();