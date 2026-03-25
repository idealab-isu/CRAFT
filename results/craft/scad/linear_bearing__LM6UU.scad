// LM6UU-style linear bearing (single connected solid)
// Target key dimensions: 6.0mm bore, 12.0mm outer diameter, 19.0mm length

$fn = 128;

// Key dimensions
bore_diameter_mm  = 6.0;   // through bore
outer_diameter_mm = 12.0;  // outer diameter
length_mm         = 19.0;  // overall length

// Feature tuning (kept small and derived from dimensions)
groove_depth_mm   = 0.35;                 // shallow OD grooves
groove_length_mm  = 1.6;
groove_spacing_mm = length_mm * 0.62;     // positions of the two grooves (center-to-center)

chamfer_mm        = 0.6;                  // end chamfer size
eps_mm            = 0.02;                 // boolean robustness

module linear_bearing_LM6UU() {
    od_r = outer_diameter_mm/2;
    id_r = bore_diameter_mm/2;

    // Ensure grooves stay within the body
    groove_z = min(groove_spacing_mm/2, length_mm/2 - groove_length_mm/2 - chamfer_mm);

    difference() {
        // Outer sleeve with slight end chamfers (single connected solid)
        union() {
            // Main body
            cylinder(r=od_r, h=length_mm - 2*chamfer_mm, center=true);

            // End chamfers as short frustums
            translate([0,0, (length_mm/2 - chamfer_mm/2)])
                cylinder(r1=od_r - chamfer_mm, r2=od_r, h=chamfer_mm, center=true);
            translate([0,0, -(length_mm/2 - chamfer_mm/2)])
                cylinder(r1=od_r, r2=od_r - chamfer_mm, h=chamfer_mm, center=true);
        }

        // Through bore
        cylinder(r=id_r, h=length_mm + 2*eps_mm, center=true);

        // Two shallow OD grooves (cut into the sleeve)
        translate([0,0, groove_z])
            cylinder(r=od_r - groove_depth_mm, h=groove_length_mm, center=true);
        translate([0,0, -groove_z])
            cylinder(r=od_r - groove_depth_mm, h=groove_length_mm, center=true);
    }
}

linear_bearing_LM6UU();