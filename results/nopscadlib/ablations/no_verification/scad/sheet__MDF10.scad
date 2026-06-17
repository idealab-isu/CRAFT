// Parameters
sheet_length = 200; //[100:400:1]
sheet_width = 150; //[75:300:1]
sheet_thickness = 2; //[1:6:0.5]
corner_radius = 12; //[6:24:1]
hole_diameter = 6; //[3:12:0.5]
hole_edge_offset = 15; //[8:30:1]
chamfer_size = 0.8; //[0.3:2:0.1]
overlap = 1; //[0.5:2:0.1]

// Base Shapes
module sheet_body() {
  color("Silver")
  translate([0, 0, 0])
    cube([sheet_length, sheet_width, sheet_thickness], center=true);
}

module rounded_corners() {
  color("Silver")
  translate([0, 0, 0])
    linear_extrude(height=sheet_thickness, center=true)
      offset(r=corner_radius)
        polygon(points=[
          [-sheet_length/2 + corner_radius, -sheet_width/2],
          [sheet_length/2 - corner_radius, -sheet_width/2],
          [sheet_length/2, -sheet_width/2 + corner_radius],
          [sheet_length/2, sheet_width/2 - corner_radius],
          [sheet_length/2 - corner_radius, sheet_width/2],
          [-sheet_length/2 + corner_radius, sheet_width/2],
          [-sheet_length/2, sheet_width/2 - corner_radius],
          [-sheet_length/2, -sheet_width/2 + corner_radius]
        ]);
}

module mounting_hole(position) {
  translate(position)
    cylinder(r=hole_diameter/2, h=sheet_thickness + 2*overlap, center=true);
}

module chamfered_edges() {
  color("Silver")
  translate([0, 0, 0])
    linear_extrude(height=sheet_thickness + 2*overlap, center=true)
      offset(delta=-chamfer_size)
        polygon(points=[
          [-sheet_length/2 + chamfer_size, -sheet_width/2 + chamfer_size],
          [sheet_length/2 - chamfer_size, -sheet_width/2 + chamfer_size],
          [sheet_length/2 - chamfer_size, sheet_width/2 - chamfer_size],
          [-sheet_length/2 + chamfer_size, sheet_width/2 - chamfer_size]
        ]);
}

// Operations
module sheet_outline_union() {
  union() {
    rounded_corners();
    sheet_body();
  }
}

module mounting_holes() {
  union() {
    mounting_hole([-sheet_length/2 + hole_edge_offset, -sheet_width/2 + hole_edge_offset, 0]);
    mounting_hole([sheet_length/2 - hole_edge_offset, -sheet_width/2 + hole_edge_offset, 0]);
    mounting_hole([sheet_length/2 - hole_edge_offset, sheet_width/2 - hole_edge_offset, 0]);
    mounting_hole([-sheet_length/2 + hole_edge_offset, sheet_width/2 - hole_edge_offset, 0]);
  }
}

module sheet_with_holes() {
  difference() {
    sheet_outline_union();
    mounting_holes();
  }
}

module sheet_with_chamfer() {
  difference() {
    sheet_with_holes();
    chamfered_edges();
  }
}

// Final Output
sheet_with_chamfer();