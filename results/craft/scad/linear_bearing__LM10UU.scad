// LM10UU-style linear bearing (single connected solid)
// Target: 10.0mm bore, 19.0mm OD, 29.0mm length

$fn = 128;

// Parameters
bore_diameter_mm = 10.0;          //[5.0:20.0:0.1]
outer_diameter_mm = 19.0;         //[10.0:38.0:0.1]
length_mm = 29.0;                //[15.0:58.0:0.1]
bore_clearance_mm = 0.1;         //[0.0:0.5:0.01]

// Cosmetic outer grooves (LMxxUU typically has 2 shallow grooves)
groove_depth_mm = 0.5;           //[0.0:1.5:0.1]
groove_length_mm = 1.5;          //[0.0:4.0:0.1]
groove_offset_from_end_mm = 3.0; //[0.0:8.0:0.1]

// Small overlap to avoid coincident faces
overlap_mm = 0.2;                //[0.05:1.0:0.05]

module lm10uu_bearing() {
  od_r = outer_diameter_mm/2;
  id_r = bore_diameter_mm/2 + bore_clearance_mm;

  // Clamp groove placement so it always stays within the bearing length
  groove_center_from_mid = max(0, length_mm/2 - groove_offset_from_end_mm - groove_length_mm/2);

  color([0.85, 0.85, 0.8])
  difference() {
    // Outer sleeve
    cylinder(r=od_r, h=length_mm, center=true);

    // Through bore
    cylinder(r=id_r, h=length_mm + 2*overlap_mm, center=true);

    // Two shallow outer grooves (subtractive)
    if (groove_depth_mm > 0 && groove_length_mm > 0) {
      for (zsgn = [-1, 1]) {
        translate([0, 0, zsgn * groove_center_from_mid])
          cylinder(r=od_r - groove_depth_mm, h=groove_length_mm + 2*overlap_mm, center=true);
      }
    }
  }
}

lm10uu_bearing();