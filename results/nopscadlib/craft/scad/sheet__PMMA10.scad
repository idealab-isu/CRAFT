// Parameters
sheet_length = 200; //[100:400:1]
sheet_width = 150; //[75:300:1]
sheet_thickness = 2; //[1:6:0.5]
corner_radius = 12; //[6:24:1]
hole_diameter = 6; //[3:12:0.5]
hole_edge_offset = 15; //[8:30:1]
chamfer_size = 0.8; //[0.3:2:0.1]
overlap = 1; //[0.5:2:0.1]

// Base shapes
module sheet_body() {
  translate([0, 0, 0])
    cube([sheet_length, sheet_width, sheet_thickness], center=true);
}

module rounded_corner(pos) {
  translate(pos)
    cylinder(r=corner_radius, h=sheet_thickness + 2*overlap, center=true);
}

module mounting_hole(pos) {
  translate(pos)
    cylinder(r=hole_diameter/2, h=sheet_thickness + 2*overlap, center=true);
}

module chamfer_kernel() {
  sphere(r=chamfer_size, center=true);
}

// Operations
module rounded_corners_union() {
  union() {
    rounded_corner([sheet_length/2 - corner_radius, sheet_width/2 - corner_radius, 0]);
    rounded_corner([-(sheet_length/2 - corner_radius), sheet_width/2 - corner_radius, 0]);
    rounded_corner([-(sheet_length/2 - corner_radius), -(sheet_width/2 - corner_radius), 0]);
    rounded_corner([sheet_length/2 - corner_radius, -(sheet_width/2 - corner_radius), 0]);
  }
}

module sheet_with_rounded_corners() {
  hull() {
    sheet_body();
    rounded_corners_union();
  }
}

module mounting_holes_union() {
  union() {
    mounting_hole([sheet_length/2 - hole_edge_offset, sheet_width/2 - hole_edge_offset, 0]);
    mounting_hole([-(sheet_length/2 - hole_edge_offset), sheet_width/2 - hole_edge_offset, 0]);
    mounting_hole([-(sheet_length/2 - hole_edge_offset), -(sheet_width/2 - hole_edge_offset), 0]);
    mounting_hole([sheet_length/2 - hole_edge_offset, -(sheet_width/2 - hole_edge_offset), 0]);
  }
}

module sheet_minus_holes() {
  difference() {
    sheet_with_rounded_corners();
    mounting_holes_union();
  }
}

module chamfer_edges() {
  minkowski() {
    sheet_minus_holes();
    chamfer_kernel();
  }
}

// Final output
chamfer_edges();