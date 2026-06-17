// Sheet MDF (single connected solid with rounded corners + top-edge chamfer)

sheet_L   = 2440; //[1220:4880:1]
sheet_W   = 1220; //[610:2440:1]
sheet_T   = 18;   //[9:36:1]
corner_R  = 10;   //[2:40:1]
chamfer_C = 1.5;  //[0.5:5:0.5]
overlap   = 1;    //[0.5:2:0.5]

$fn = 96;

// 2D rounded rectangle profile
module rounded_rect_2d(L, W, R) {
  R2 = min(R, min(L, W)/2);
  hull() {
    for (sx = [-1, 1], sy = [-1, 1])
      translate([sx*(L/2 - R2), sy*(W/2 - R2)])
        circle(r=R2);
  }
}

// Main solid: rounded corners via linear_extrude
module rounded_sheet() {
  linear_extrude(height=sheet_T, center=true, convexity=10)
    rounded_rect_2d(sheet_L, sheet_W, corner_R);
}

// Chamfer cutters (remove material from the TOP edges only)
// Use long cutters that fully intersect the sheet to avoid blank/degenerate renders.
module chamfer_cutters() {
  cutter_len = max(sheet_L, sheet_W) + 4*overlap;

  // Cut along the two X edges (x = +/- L/2)
  for (sx = [-1, 1]) {
    translate([sx*(sheet_L/2 - chamfer_C/2), 0, sheet_T/2 - chamfer_C/2])
      rotate([0, 45, 0])  // bevel in X-Z plane
        cube([chamfer_C, cutter_len, chamfer_C], center=true);
  }

  // Cut along the two Y edges (y = +/- W/2)
  for (sy = [-1, 1]) {
    translate([0, sy*(sheet_W/2 - chamfer_C/2), sheet_T/2 - chamfer_C/2])
      rotate([45, 0, 0])  // bevel in Y-Z plane
        cube([cutter_len, chamfer_C, chamfer_C], center=true);
  }
}

// Final output (one connected solid)
difference() {
  rounded_sheet();
  chamfer_cutters();
}