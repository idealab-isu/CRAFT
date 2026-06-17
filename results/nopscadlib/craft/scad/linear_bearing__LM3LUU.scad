// Long linear bearing: 3.0mm bore, 7.0mm OD, 19.0mm length
// One connected solid (bearing body only)

// Parameters
bore_diameter_mm  = 3.0;  //[1.5:6.0:0.1]
outer_diameter_mm = 7.0;  //[3.5:14.0:0.1]
length_mm         = 19.0; //[9.5:38.0:0.1]
centered          = 1;    //[0:1:1]

grooves_enabled   = 0;    //[0:1:1]
groove_count      = 0;    //[0:2:1]
groove_diameter_mm= 6.2;  //[4.0:13.5:0.1]
groove_length_mm  = 2.0;  //[0.5:6.0:0.1]
groove_spacing_mm = 12.0; //[4.0:30.0:0.1]

eps_mm            = 0.2;  //[0.05:0.5:0.05]
overlap_mm        = 0.2;  //[0.05:1.0:0.05]

$fn = 96;

module linear_bearing() {
  zc = centered ? 0 : length_mm/2;

  color([0.85, 0.85, 0.8])
  translate([0, 0, zc])
  difference() {
    // Outer body
    cylinder(h=length_mm, r=outer_diameter_mm/2, center=true);

    // Through bore
    cylinder(h=length_mm + 2*eps_mm, r=bore_diameter_mm/2, center=true);

    // Optional external grooves (cut into OD)
    if (grooves_enabled && groove_count > 0) {
      for (i = [0:groove_count-1]) {
        zpos = (groove_count==1)
          ? 0
          : (- (groove_count-1)/2 + i) * groove_spacing_mm;

        translate([0, 0, zpos])
          difference() {
            // Remove a ring from the OD region
            cylinder(h=groove_length_mm, r=outer_diameter_mm/2 + eps_mm, center=true);
            // Keep inner portion up to groove diameter
            cylinder(h=groove_length_mm + 2*eps_mm, r=groove_diameter_mm/2, center=true);
          }
      }
    }
  }
}

linear_bearing();