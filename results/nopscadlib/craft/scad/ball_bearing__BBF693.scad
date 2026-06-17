$fn = 128;

// Target dimensions (mm)
bore_diameter_mm   = 3.0;
outer_diameter_mm  = 8.0;
width_mm           = 3.0;
flange_diameter_mm = 9.5;

// Visual/feature parameters (kept small so OD/width/flange stay correct)
flange_width_mm    = 0.6;   // axial thickness of flange (part of total width)
outer_race_wall_mm = 0.9;   // radial thickness of outer ring
inner_race_wall_mm = 0.9;   // radial thickness of inner ring
ball_diameter_mm   = 1.2;
ball_count         = 8;

overlap_mm         = 0.08;  // overlap to ensure single connected solid
bore_clear_mm      = 0.02;  // tiny clearance so bore is visibly open

module flanged_bearing_connected() {

    // Radii
    r_bore   = bore_diameter_mm/2;
    r_outer  = outer_diameter_mm/2;
    r_flange = flange_diameter_mm/2;

    // Axial extents
    z_min = -width_mm/2;
    z_max =  width_mm/2;

    // Flange placed on bottom face, within total width
    z_flange_center = z_min + flange_width_mm/2;

    // Ring radii
    r_outer_inner = r_outer - outer_race_wall_mm;
    r_inner_outer = r_bore + inner_race_wall_mm;

    // Ball pitch radius (between races)
    r_pitch = (r_outer_inner + r_inner_outer)/2;

    // Keep balls between races (and slightly intersect both races for connectivity)
    r_pitch_safe = max(r_pitch, r_inner_outer + ball_diameter_mm/2 - overlap_mm/2);
    r_pitch_safe = min(r_pitch_safe, r_outer_inner - ball_diameter_mm/2 + overlap_mm/2);

    // Through-bore cutter (slightly larger than nominal so it reads clearly as a hole)
    r_bore_cut = r_bore + bore_clear_mm;

    difference() {
        // ONE connected solid (outer ring + inner ring + flange + balls)
        union() {
            // Outer ring
            difference() {
                cylinder(r=r_outer, h=width_mm, center=true);
                cylinder(r=r_outer_inner, h=width_mm + 2*overlap_mm, center=true);
            }

            // Inner ring
            difference() {
                cylinder(r=r_inner_outer, h=width_mm, center=true);
                cylinder(r=r_bore, h=width_mm + 2*overlap_mm, center=true);
            }

            // Flange (overlaps outer ring)
            translate([0,0,z_flange_center])
                cylinder(r=r_flange, h=flange_width_mm + 2*overlap_mm, center=true);

            // Balls (slightly intersect races so everything is one connected solid)
            for (i = [0:ball_count-1]) {
                rotate([0,0,i*360/ball_count])
                    translate([r_pitch_safe, 0, 0])
                        sphere(r=ball_diameter_mm/2);
            }
        }

        // Cut a clean through-bore so front/back views show an opening (not a "sphere")
        cylinder(r=r_bore_cut, h=width_mm + 4*overlap_mm, center=true);
    }
}

flanged_bearing_connected();