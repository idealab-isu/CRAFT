// Long linear bearing: 4.0mm bore, 8.0mm OD, 23.0mm length
bore_diameter_mm  = 4;   //[2:8:0.1]
outer_diameter_mm = 8;   //[4:16:0.1]
length_mm         = 23;  //[12:46:0.5]
centered          = 1;   //[0:1:1]

fit_clearance_mm     = 0.2; //[0:0.6:0.05]
connect_overlap_mm   = 1;   //[0.5:2:0.1]

$fn = 128;

module long_linear_bearing() {
  bore_r  = (bore_diameter_mm + fit_clearance_mm)/2;
  outer_r = outer_diameter_mm/2;

  // Simple linear bearing sleeve with visible end reliefs + through-bore
  // (One connected solid; all features are subtractions)
  relief_depth = min(0.6, outer_r - bore_r - 0.2);   // radial relief depth
  relief_len   = min(2.0, length_mm/6);              // axial relief length at each end
  mid_relief_len = min(1.2, length_mm/10);           // small mid relief band

  difference() {
    // Outer body
    cylinder(h=length_mm, r=outer_r, center=centered);

    // Through bore (always centered so it cuts fully regardless of centered flag)
    cylinder(h=length_mm + 2*connect_overlap_mm, r=bore_r, center=true);

    // End reliefs (slightly larger ID near both ends)
    for (s = [-1, 1]) {
      translate([0, 0, s*(length_mm/2 - relief_len/2)])
        cylinder(h=relief_len + connect_overlap_mm, r=bore_r + relief_depth, center=true);
    }

    // Small mid relief band to suggest bearing race/feature
    cylinder(h=mid_relief_len + connect_overlap_mm, r=bore_r + relief_depth*0.6, center=true);
  }
}

long_linear_bearing();