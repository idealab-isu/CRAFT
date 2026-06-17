// Sheet parameters (mm)
sheet_L = 100;          // length
sheet_W = 100;          // width
sheet_T = 25.4 * 5/16;  // ~5/16" = 7.9375 mm

$fn = 64;

// One connected solid: a single sheet centered at origin
module sheet_body() {
  cube([sheet_L, sheet_W, sheet_T], center=true);
}

sheet_body();