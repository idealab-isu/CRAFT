// Linear bearing: 6mm bore, 12mm outer diameter, 19mm length
bore_diameter_mm   = 6;    //[3:12:0.1]
outer_diameter_mm  = 12;   //[6:24:0.1]
length_mm          = 19;   //[10:38:0.1]

// Optional visual/print tweaks (do not change nominal dimensions)
fit_clearance_mm   = 0.0;  //[0:0.6:0.05]  // added to bore diameter
groove_depth_mm    = 0.35; //[0:1:0.05]    // shallow outer grooves (typical bearing look)
groove_width_mm    = 1.2;  //[0:4:0.1]
groove_offset_mm   = 3.0;  //[0:8:0.1]     // distance from each end to groove center
edge_chamfer_mm    = 0.4;  //[0:1.5:0.05]
connect_overlap_mm = 0.2;  //[0.05:1:0.05]
$fn = 128;

module linear_bearing_6x12x19() {
    bore_r  = bore_diameter_mm/2 + fit_clearance_mm/2;
    outer_r = outer_diameter_mm/2;

    // Keep grooves within the length
    groove_center_from_end = min(groove_offset_mm,
                                 max(0, length_mm/2 - groove_width_mm/2 - connect_overlap_mm));
    z_groove = length_mm/2 - groove_center_from_end;

    // Clamp chamfer so it can't invert geometry
    chamfer = min(edge_chamfer_mm, outer_r - bore_r - 0.01);

    color("Silver")
    difference() {
        // ONE connected outer sleeve (single cylinder)
        cylinder(r=outer_r, h=length_mm, center=true);

        // Through bore
        cylinder(r=bore_r, h=length_mm + 2*connect_overlap_mm, center=true);

        // Outer grooves: subtract only the annular band (NOT the whole OD cylinder)
        if (groove_depth_mm > 0 && groove_width_mm > 0) {
            for (s = [-1, 1]) {
                translate([0, 0, s*z_groove])
                    difference() {
                        // limit subtraction to the outer ring region
                        cylinder(r=outer_r + connect_overlap_mm,
                                 h=groove_width_mm + 2*connect_overlap_mm, center=true);
                        // keep inner portion so we only cut a shallow groove
                        cylinder(r=outer_r - groove_depth_mm,
                                 h=groove_width_mm + 4*connect_overlap_mm, center=true);
                    }
            }
        }

        // End chamfers: subtract conical rings (NOT full cones that would slice the body)
        if (chamfer > 0) {
            for (s = [-1, 1]) {
                translate([0, 0, s*(length_mm/2 - chamfer/2)])
                    difference() {
                        cylinder(r=outer_r + connect_overlap_mm,
                                 h=chamfer + 2*connect_overlap_mm, center=true);
                        cylinder(r1=outer_r - chamfer, r2=outer_r,
                                 h=chamfer + 2*connect_overlap_mm, center=true);
                    }
            }
        }
    }
}

linear_bearing_6x12x19();