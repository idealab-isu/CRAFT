// Parameters
sheet_length = 600; //[300:1200:1]
sheet_width = 400;  //[200:800:1]
sheet_thickness = 18; //[9:36:1]
corner_cut = 5;     //[0:30:1]
overlap = 1;        //[0.5:2:0.5]

// Main MDF Sheet Panel
module mdf_sheet_panel() {
  color([0.85, 0.85, 0.8])
    cube([sheet_length, sheet_width, sheet_thickness], center=true);
}

// Corner cutout (subtractive), positioned at a corner and extending outward
module corner_cutout_at_corner(sx, sy, cut) {
  // sx, sy are +/-1 selecting which corner
  translate([sx*(sheet_length/2 - cut/2), sy*(sheet_width/2 - cut/2), 0])
    cube([cut + 2*overlap, cut + 2*overlap, sheet_thickness + 2*overlap], center=true);
}

// Final MDF Sheet with Corner Cuts (one connected solid)
module mdf_sheet_with_corner_cuts() {
  cut = max(0, min(corner_cut, min(sheet_length, sheet_width)/2));

  difference() {
    mdf_sheet_panel();

    if (cut > 0) {
      corner_cutout_at_corner( 1,  1, cut);
      corner_cutout_at_corner(-1,  1, cut);
      corner_cutout_at_corner( 1, -1, cut);
      corner_cutout_at_corner(-1, -1, cut);
    }
  }
}

// Render
mdf_sheet_with_corner_cuts();