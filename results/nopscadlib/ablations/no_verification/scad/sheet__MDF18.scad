// Sheet MDF (single connected solid with rounded corners + mounting holes)
// No text/labels

$fn = 96;

// Parameters
sheet_L = 600; //[300:1200:1]
sheet_W = 400; //[200:800:1]
sheet_T = 18;  //[9:36:1]
corner_R = 10; //[0:40:1]
hole_d = 6;    //[3:12:1]
hole_edge_offset = 25; //[10:80:1]
hole_clearance = 0.5;  //[0:1.5:0.1]

// Derived / safety
eps = 0.01;
r_hole = hole_d/2 + hole_clearance;

// Clamp to avoid invalid geometry
corner_R_eff = min(corner_R, min(sheet_L, sheet_W)/2 - eps);
hole_off_x = min(hole_edge_offset, sheet_L/2 - corner_R_eff - r_hole - eps);
hole_off_y = min(hole_edge_offset, sheet_W/2 - corner_R_eff - r_hole - eps);

module rounded_rect_2d(L, W, R) {
  // Robust rounded rectangle in 2D using hull of corner circles
  if (R <= 0) {
    square([L, W], center=true);
  } else {
    hull() {
      for (sx = [-1, 1], sy = [-1, 1])
        translate([sx*(L/2 - R), sy*(W/2 - R)])
          circle(r=R);
    }
  }
}

module sheet_solid() {
  // Extruded rounded rectangle = MDF sheet body
  linear_extrude(height=sheet_T, center=true, convexity=10)
    rounded_rect_2d(sheet_L, sheet_W, corner_R_eff);
}

module mounting_holes() {
  // Through-holes (subtractive)
  for (sx = [-1, 1], sy = [-1, 1])
    translate([sx*(sheet_L/2 - hole_off_x), sy*(sheet_W/2 - hole_off_y), 0])
      cylinder(r=r_hole, h=sheet_T + 2, center=true);
}

difference() {
  sheet_solid();
  mounting_holes();
}