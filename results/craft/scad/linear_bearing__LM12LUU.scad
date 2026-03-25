$fn = 128;

// Long linear bearing (LM12LUU-style): 12.0mm bore, 21.0mm OD, 57.0mm length
bore_diameter_mm  = 12.0;
outer_diameter_mm = 21.0;
length_mm         = 57.0;

bore_radius_mm  = bore_diameter_mm/2;
outer_radius_mm = outer_diameter_mm/2;

// Typical external grooves on LM..UU bearings (cut into OD)
groove_count      = 2;
groove_width_mm   = 3.0;
groove_depth_mm   = 0.6;
groove_spacing_mm = 35.0;

eps_mm = 0.2;

// ---------- Bearing ----------
module linear_bearing() {
    difference() {
        // Outer cylinder: OD=21, L=57
        cylinder(r=outer_radius_mm, h=length_mm, center=true);

        // Through bore: ID=12
        cylinder(r=bore_radius_mm, h=length_mm + 2*eps_mm, center=true);

        // External grooves (subtractive rings)
        if (groove_count > 0) {
            for (i = [0:groove_count-1]) {
                zpos =
                    (groove_count == 1) ? 0 :
                    (i == 0 ? -groove_spacing_mm/2 : groove_spacing_mm/2);

                translate([0, 0, zpos])
                    difference() {
                        // Volume to remove (a ring at the OD)
                        cylinder(r=outer_radius_mm + eps_mm, h=groove_width_mm, center=true);
                        // Keep inner portion so only a shallow groove is removed
                        cylinder(r=outer_radius_mm - groove_depth_mm, h=groove_width_mm + 2*eps_mm, center=true);
                    }
            }
        }
    }
}

// One connected solid (single body with internal void)
linear_bearing();