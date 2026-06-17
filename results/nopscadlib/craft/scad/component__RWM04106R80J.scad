// 3W vitreous enamel (cement/ceramic) axial resistor (e.g., 6R8 3W)
// One connected solid (geometry only). No text/labels.
// Form factor: larger ceramic body, metal end caps, conical lead terminations.
// NOTE: Many real vitreous enamel resistors are printed (no bands). Bands optional here.

$fn = 96;

// --- User parameters ---
body_length_mm        = 22;   //[12:40:0.5]
body_diameter_mm      = 9.5;  //[5:16:0.1]

// End caps (metal ferrules)
end_cap_length_mm     = 2.6;  //[1.0:6:0.1]
end_cap_diameter_mm   = 9.2;  //[5:18:0.1]

// Conical termination from cap to lead (typical power resistor look)
cone_length_mm        = 2.2;  //[0.8:6:0.1]
cone_tip_diameter_mm  = 1.8;  //[0.8:4:0.1]

// Leads
lead_diameter_mm      = 0.8;  //[0.4:1.6:0.05]
lead_length_each_mm   = 28;   //[10:80:0.5]

// Optional bands (set to 0 to disable)
show_bands            = 1;    //[0:1]
band_thickness_mm     = 0.35; //[0.1:0.8:0.05]
band_width_mm         = 1.2;  //[0.5:3.0:0.1]
band_gap_mm           = 1.0;  //[0.4:3.0:0.1]
band_set_offset_mm    = 4.0;  //[1.0:12.0:0.1]

// Overlap to guarantee watertight union
overlap_mm            = 0.6;  //[0.2:2:0.1]

// --- Helpers ---
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

module resistor_vitreous_enamel_3W() {
    body_r = body_diameter_mm/2;
    cap_r  = end_cap_diameter_mm/2;
    lead_r = lead_diameter_mm/2;
    cone_r_tip = cone_tip_diameter_mm/2;

    // Keep caps close to body diameter (power resistor ferrules are usually similar)
    cap_r2 = max(cap_r, body_r*0.98);

    // Layout along X axis
    x_body_min = -body_length_mm/2;
    x_body_max =  body_length_mm/2;

    // Cap centers (slightly overlapping into body)
    x_capL_c = x_body_min - end_cap_length_mm/2 + overlap_mm;
    x_capR_c = x_body_max + end_cap_length_mm/2 - overlap_mm;

    // Cone centers (between cap and lead)
    x_coneL_c = x_body_min - end_cap_length_mm - cone_length_mm/2 + overlap_mm;
    x_coneR_c = x_body_max + end_cap_length_mm + cone_length_mm/2 - overlap_mm;

    // Cone outer ends (where lead starts)
    x_coneL_end = x_body_min - end_cap_length_mm - cone_length_mm + overlap_mm;
    x_coneR_end = x_body_max + end_cap_length_mm + cone_length_mm - overlap_mm;

    // Lead centers
    x_leadL_c = x_coneL_end - lead_length_each_mm/2;
    x_leadR_c = x_coneR_end + lead_length_each_mm/2;

    // Slightly rounded ceramic body ends
    body_round_len = clamp(body_length_mm*0.22, 2.5, 6.0);

    union() {
        // --- Ceramic/cement body ---
        color("Gainsboro")
        hull() {
            translate([x_body_min + body_round_len/2, 0, 0])
                rotate([0,90,0]) cylinder(h=body_round_len, r=body_r, center=true);
            translate([x_body_max - body_round_len/2, 0, 0])
                rotate([0,90,0]) cylinder(h=body_round_len, r=body_r, center=true);
        }

        // --- Metal end caps + conical terminations + leads (all connected) ---
        color("Silver") {
            // End caps
            translate([x_capL_c, 0, 0])
                rotate([0,90,0]) cylinder(h=end_cap_length_mm, r=cap_r2, center=true);
            translate([x_capR_c, 0, 0])
                rotate([0,90,0]) cylinder(h=end_cap_length_mm, r=cap_r2, center=true);

            // Conical terminations (cap -> lead)
            // Left: wide at cap side, narrow at lead side
            translate([x_coneL_c, 0, 0])
                rotate([0,90,0]) cylinder(h=cone_length_mm, r1=cap_r2*0.70, r2=cone_r_tip, center=true);
            // Right: wide at cap side, narrow at lead side
            translate([x_coneR_c, 0, 0])
                rotate([0,90,0]) cylinder(h=cone_length_mm, r1=cap_r2*0.70, r2=cone_r_tip, center=true);

            // Leads (start at cone tips; overlap ensures connection)
            translate([x_leadL_c, 0, 0])
                rotate([0,90,0]) cylinder(h=lead_length_each_mm + overlap_mm, r=lead_r, center=true);
            translate([x_leadR_c, 0, 0])
                rotate([0,90,0]) cylinder(h=lead_length_each_mm + overlap_mm, r=lead_r, center=true);
        }

        // --- Optional bands (geometry only; many real parts are printed instead) ---
        if (show_bands == 1) {
            band_r = body_r + band_thickness_mm;

            x_band0 = x_body_min + band_set_offset_mm;
            x_band1 = x_band0 + (band_width_mm + band_gap_mm);
            x_band2 = x_band1 + (band_width_mm + band_gap_mm);
            x_band3 = x_band2 + (band_width_mm + band_gap_mm);

            x_band0c = clamp(x_band0, x_body_min + band_width_mm/2, x_body_max - band_width_mm/2);
            x_band1c = clamp(x_band1, x_body_min + band_width_mm/2, x_body_max - band_width_mm/2);
            x_band2c = clamp(x_band2, x_body_min + band_width_mm/2, x_body_max - band_width_mm/2);
            x_band3c = clamp(x_band3, x_body_min + band_width_mm/2, x_body_max - band_width_mm/2);

            // 6R8 example: blue, gray, gold, gold (kept as simple rings)
            color([0.10, 0.20, 0.70])
                translate([x_band0c, 0, 0]) rotate([0,90,0])
                    cylinder(h=band_width_mm, r=band_r, center=true);

            color([0.55, 0.55, 0.55])
                translate([x_band1c, 0, 0]) rotate([0,90,0])
                    cylinder(h=band_width_mm, r=band_r, center=true);

            color([0.85, 0.70, 0.20])
                translate([x_band2c, 0, 0]) rotate([0,90,0])
                    cylinder(h=band_width_mm, r=band_r, center=true);

            color([0.85, 0.70, 0.20])
                translate([x_band3c, 0, 0]) rotate([0,90,0])
                    cylinder(h=band_width_mm, r=band_r, center=true);
        }
    }
}

resistor_vitreous_enamel_3W();