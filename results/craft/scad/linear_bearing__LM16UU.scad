$fn = 128;

// LM16UU nominal dimensions (mm)
bore_diameter_mm  = 16.0;
outer_diameter_mm = 28.0;
length_mm         = 37.0;

// Detail parameters (kept simple but recognizable)
connect_overlap_mm = 0.2;

// End seal / cap geometry (visual detail only)
seal_thickness_mm        = 2.0;   // axial thickness of each end seal
seal_outer_step_mm       = 0.6;   // slight OD step at ends
seal_bore_clearance_mm   = 0.4;   // seal lip clearance to shaft

// Retaining ring groove (visual detail only)
groove_width_mm          = 1.2;   // axial width
groove_depth_mm          = 0.5;   // radial depth into OD
groove_offset_from_end_mm = 3.0;  // distance from each end to groove center

module linear_bearing_LM16UU() {
    difference() {
        // Outer body
        cylinder(d=outer_diameter_mm, h=length_mm, center=true);

        // Through bore
        cylinder(d=bore_diameter_mm, h=length_mm + 2*connect_overlap_mm, center=true);

        // Two OD retaining-ring grooves (subtractive)
        for (s = [-1, 1]) {
            translate([0, 0, s*(length_mm/2 - groove_offset_from_end_mm)])
                cylinder(d=outer_diameter_mm - 2*groove_depth_mm,
                         h=groove_width_mm + 2*connect_overlap_mm,
                         center=true);
        }
    }

    // End seals (added as connected solids with slight OD step)
    for (s = [-1, 1]) {
        translate([0, 0, s*(length_mm/2 - seal_thickness_mm/2 + connect_overlap_mm/2)])
            difference() {
                cylinder(d=outer_diameter_mm + 2*seal_outer_step_mm,
                         h=seal_thickness_mm,
                         center=true);
                cylinder(d=bore_diameter_mm + 2*seal_bore_clearance_mm,
                         h=seal_thickness_mm + 2*connect_overlap_mm,
                         center=true);
            }
    }
}

linear_bearing_LM16UU();