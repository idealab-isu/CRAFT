// Parameters
sheet_length = 200; //[100:400:1]
sheet_width = 200; //[100:400:1]
sheet_thickness = 2; //[1:6:0.5]
corner_radius = 12; //[6:24:1]
hole_diameter = 6; //[3:12:0.5]
hole_edge_offset = 20; //[10:40:1]
chamfer_size = 0.8; //[0.2:2:0.1]
overlap = 1; //[0.5:2:0.1]

// Base shapes
module sheet_body() {
  translate([0, 0, -sheet_thickness/2])
    cube([sheet_length, sheet_width, sheet_thickness], center=true);
}

module rounded_corners() {
  translate([sheet_length/2 - corner_radius, sheet_width/2 - corner_radius, 0])
    cylinder(r=corner_radius, h=sheet_thickness + 2*overlap, center=true);
}

module mounting_holes() {
  translate([sheet_length/2 - hole_edge_offset, sheet_width/2 - hole_edge_offset, 0])
    cylinder(r=hole_diameter/2, h=sheet_thickness + 4*overlap, center=true);
}

module chamfer_edges() {
  sphere(r=chamfer_size, center=true);
}

// Operations
module rounded_corners_all() {
  union() {
    rounded_corners();
    mirror([1, 0, 0]) rounded_corners();
    mirror([0, 1, 0]) rounded_corners();
    mirror([1, 1, 0]) rounded_corners();
  }
}

module sheet_with_rounded_corners() {
  minkowski() {
    sheet_body();
    rounded_corners_all();
  }
}

module mounting_holes_all() {
  union() {
    mounting_holes();
    mirror([1, 0, 0]) mounting_holes();
    mirror([0, 1, 0]) mounting_holes();
    mirror([1, 1, 0]) mounting_holes();
  }
}

module sheet_rounded_with_holes() {
  difference() {
    sheet_with_rounded_corners();
    mounting_holes_all();
  }
}

module sheet_rounded_holes_chamfered() {
  minkowski() {
    sheet_rounded_with_holes();
    chamfer_edges();
  }
}

// Final output
color("Silver") sheet_rounded_holes_chamfered();