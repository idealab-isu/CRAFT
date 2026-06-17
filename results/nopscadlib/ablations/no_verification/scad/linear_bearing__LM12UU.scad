// Linear bearing (LM12UU-like) — 12mm bore, 21mm OD, 30mm length
// One connected solid; no extra parts.

$fn = 128;

// Parameters (mm)
bore_diameter_mm  = 12.0;
outer_diameter_mm = 21.0;
length_mm         = 30.0;

// Detail parameters (kept subtle; do not change main dimensions)
edge_break_mm     = 0.4;   // small end bevel
overlap_mm        = 0.2;   // boolean overlap
groove_depth_mm   = 0.6;   // shallow outer grooves
groove_width_mm   = 1.2;   // groove axial width
groove_offset_mm  = 3.0;   // distance from each end to groove center

module linear_bearing_12_21_30() {
    r_out = outer_diameter_mm/2;
    r_in  = bore_diameter_mm/2;

    // Keep grooves within length
    groove_center_from_end = max(groove_offset_mm, groove_width_mm/2 + edge_break_mm);
    z_g1 =  length_mm/2 - groove_center_from_end;
    z_g2 = -length_mm/2 + groove_center_from_end;

    difference() {
        // Outer body with slight end bevels (single connected solid)
        union() {
            cylinder(r=r_out, h=length_mm, center=true);

            translate([0, 0,  length_mm/2 - edge_break_mm/2])
                cylinder(r1=r_out, r2=r_out - edge_break_mm, h=edge_break_mm, center=true);

            translate([0, 0, -length_mm/2 + edge_break_mm/2])
                cylinder(r1=r_out - edge_break_mm, r2=r_out, h=edge_break_mm, center=true);
        }

        // Through bore (guaranteed visible in top/bottom views)
        cylinder(r=r_in, h=length_mm + 2*overlap_mm, center=true);

        // Outer race grooves: subtract ONLY a thin annular band (not a full cylinder),
        // so the body remains a single connected solid and grooves are visible.
        for (z = [z_g1, z_g2]) {
            translate([0, 0, z])
                difference() {
                    cylinder(r=r_out + overlap_mm, h=groove_width_mm, center=true);
                    cylinder(r=r_out - groove_depth_mm, h=groove_width_mm + 2*overlap_mm, center=true);
                }
        }
    }
}

linear_bearing_12_21_30();