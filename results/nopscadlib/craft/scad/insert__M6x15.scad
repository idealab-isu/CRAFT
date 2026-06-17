$fn = 160;

// Target: heat-set insert, 15mm OD, 12mm long, for 6mm screw

// Parameters
outer_diameter_mm = 15.0;   //[7.5:30.0:0.1]
length_mm         = 12.0;   //[6.0:24.0:0.1]
screw_diameter_mm = 6.0;    //[3.0:12.0:0.1]

// Bore / "thread" representation (clearance for M6 screw)
bore_clearance_mm   = 0.4;  //[0.0:1.0:0.05]
bore_extra_depth_mm = 0.6;  //[0.2:2.0:0.1]

// End chamfers
entry_chamfer_mm = 0.6;     //[0.25:1.5:0.05]
end_chamfer_mm   = 0.6;     //[0.25:1.5:0.05]

// Outer heat-set features (serrations/knurl)
knurl_depth_mm         = 0.6;  //[0.2:1.5:0.05]   // protrusion beyond OD
knurl_rib_width_mm     = 1.0;  //[0.4:2.0:0.05]   // tangential width
knurl_rib_count        = 24;   //[8:48:1]
knurl_z_margin_mm      = 1.0;  //[0.0:3.0:0.1]    // keep ends cleaner
knurl_z_overlap_mm     = 0.25; //[0.0:1.0:0.05]   // overlap into body for watertight union

// Derived
outer_r = outer_diameter_mm/2;
bore_r  = (screw_diameter_mm + bore_clearance_mm)/2;

module outer_body_with_knurl() {
    union() {
        // Main cylinder (exact OD/length)
        cylinder(h=length_mm, r=outer_r, center=true);

        // Radial ribs (protrude outward, overlap into body to ensure connectivity)
        knurl_h = max(0.01, length_mm - 2*knurl_z_margin_mm);

        // Place ribs centered in Z, but ensure they overlap the main cylinder radially
        for (i = [0:knurl_rib_count-1]) {
            rotate([0,0,i*360/knurl_rib_count])
                translate([outer_r + knurl_depth_mm/2 - knurl_z_overlap_mm, 0, 0])
                    cube([knurl_depth_mm + 2*knurl_z_overlap_mm, knurl_rib_width_mm, knurl_h], center=true);
        }
    }
}

module end_chamfers_subtractive() {
    // Clamp chamfers so they can't exceed half the length (prevents invalid/empty geometry)
    ch1 = min(entry_chamfer_mm, length_mm/2 - 0.01);
    ch2 = min(end_chamfer_mm,   length_mm/2 - 0.01);

    // Subtractive conical cuts at both ends (small lead-in)
    translate([0,0, length_mm/2 - ch1/2])
        cylinder(h=ch1, r1=outer_r + 0.01, r2=max(0.01, outer_r - ch1), center=true);

    translate([0,0,-length_mm/2 + ch2/2])
        cylinder(h=ch2, r1=max(0.01, outer_r - ch2), r2=outer_r + 0.01, center=true);
}

module internal_bore_subtractive() {
    // Through bore (represents internal thread space)
    cylinder(h=length_mm + bore_extra_depth_mm, r=bore_r, center=true);

    // Slight entry countersink to make the hole visible in renders
    cs_h = min(max(entry_chamfer_mm, 0.4), length_mm/2 - 0.01);

    translate([0,0, length_mm/2 - cs_h/2])
        cylinder(h=cs_h, r1=bore_r + cs_h*0.6, r2=bore_r, center=true);

    translate([0,0,-length_mm/2 + cs_h/2])
        cylinder(h=cs_h, r1=bore_r, r2=bore_r + cs_h*0.6, center=true);
}

module threaded_insert() {
    // Ensure a single connected solid by keeping all outer features unioned,
    // and only subtracting internal/edge features.
    difference() {
        outer_body_with_knurl();
        end_chamfers_subtractive();
        internal_bore_subtractive();
    }
}

threaded_insert();