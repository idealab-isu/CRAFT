// Parameters
sheet_L = 200; //[100:400:1]
sheet_W = 150; //[75:300:1]
sheet_T = 2; //[1:6:0.5]
corner_R = 8; //[4:16:1]
hole_D = 6; //[3:12:0.5]
hole_edge_margin = 15; //[8:30:1]
chamfer_size = 0.8; //[0.2:2:0.1]
overlap = 1; //[0.5:2:0.5]

// Base shapes
module sheet_body() {
  color("Silver")
  cube([sheet_L, sheet_W, sheet_T], center=true);
}

module rounded_corners() {
  color("Silver")
  linear_extrude(height=sheet_T, center=true) {
    polygon(points=[
      [-sheet_L/2 + corner_R, -sheet_W/2],
      [sheet_L/2 - corner_R, -sheet_W/2],
      [sheet_L/2, -sheet_W/2 + corner_R],
      [sheet_L/2, sheet_W/2 - corner_R],
      [sheet_L/2 - corner_R, sheet_W/2],
      [-sheet_L/2 + corner_R, sheet_W/2],
      [-sheet_L/2, sheet_W/2 - corner_R],
      [-sheet_L/2, -sheet_W/2 + corner_R]
    ]);
  }
}

module mounting_holes() {
  color("Black")
  cylinder(r=hole_D/2, h=sheet_T + 2*overlap, center=true);
}

module chamfer_edges() {
  sphere(r=chamfer_size, center=true);
}

// Operations
module mounting_holes_all() {
  union() {
    translate([sheet_L/2 - hole_edge_margin, sheet_W/2 - hole_edge_margin, 0]) mounting_holes();
    translate([-(sheet_L/2 - hole_edge_margin), sheet_W/2 - hole_edge_margin, 0]) mounting_holes();
    translate([sheet_L/2 - hole_edge_margin, -(sheet_W/2 - hole_edge_margin), 0]) mounting_holes();
    translate([-(sheet_L/2 - hole_edge_margin), -(sheet_W/2 - hole_edge_margin), 0]) mounting_holes();
  }
}

module sheet_rounded_base() {
  minkowski() {
    rounded_corners();
    chamfer_edges();
  }
}

module sheet_with_holes() {
  difference() {
    sheet_rounded_base();
    mounting_holes_all();
  }
}

module final_sheet() {
  union() {
    sheet_with_holes();
    sheet_body();
  }
}

// Final output
final_sheet();