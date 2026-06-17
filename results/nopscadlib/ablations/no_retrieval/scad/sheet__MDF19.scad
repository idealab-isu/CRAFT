// Parameters
sheet_length = 200; //[100:400:1]
sheet_width = 150; //[75:300:1]
sheet_thickness = 2; //[1:6:0.5]
corner_radius = 12; //[6:24:1]
hole_diameter = 6; //[3:12:0.5]
hole_edge_offset = 15; //[8:30:1]
chamfer_size = 1; //[0.5:3:0.25]
overlap = 1; //[0.5:2:0.1]

// Base Shapes
module sheet_body() {
  translate([0, 0, sheet_thickness/2])
    cube([sheet_length, sheet_width, sheet_thickness], center=true);
}

module rounded_corner_cyl(pos) {
  translate(pos)
    cylinder(r=corner_radius, h=sheet_thickness + 2*overlap, center=true);
}

module mounting_hole(pos) {
  translate(pos)
    cylinder(r=hole_diameter/2, h=sheet_thickness + 4*overlap, center=true);
}

module chamfer_cut_x(pos) {
  translate(pos)
    rotate([0, 45, 0])
      cube([chamfer_size*2, sheet_width + 2*overlap, chamfer_size*2], center=true);
}

module chamfer_cut_y(pos) {
  translate(pos)
    rotate([45, 0, 0])
      cube([sheet_length + 2*overlap, chamfer_size*2, chamfer_size*2], center=true);
}

// Operations
module rounded_corners() {
  hull() {
    rounded_corner_cyl([sheet_length/2 - corner_radius, sheet_width/2 - corner_radius, 0]);
    rounded_corner_cyl([-sheet_length/2 + corner_radius, sheet_width/2 - corner_radius, 0]);
    rounded_corner_cyl([-sheet_length/2 + corner_radius, -sheet_width/2 + corner_radius, 0]);
    rounded_corner_cyl([sheet_length/2 - corner_radius, -sheet_width/2 + corner_radius, 0]);
  }
}

module sheet_with_rounded_corners() {
  intersection() {
    sheet_body();
    rounded_corners();
  }
}

module mounting_holes() {
  union() {
    mounting_hole([sheet_length/2 - hole_edge_offset, sheet_width/2 - hole_edge_offset, 0]);
    mounting_hole([-sheet_length/2 + hole_edge_offset, sheet_width/2 - hole_edge_offset, 0]);
    mounting_hole([-sheet_length/2 + hole_edge_offset, -sheet_width/2 + hole_edge_offset, 0]);
    mounting_hole([sheet_length/2 - hole_edge_offset, -sheet_width/2 + hole_edge_offset, 0]);
  }
}

module chamfer_edges() {
  union() {
    chamfer_cut_x([sheet_length/2 - chamfer_size, 0, sheet_thickness/2 - chamfer_size]);
    chamfer_cut_x([-sheet_length/2 + chamfer_size, 0, sheet_thickness/2 - chamfer_size]);
    chamfer_cut_y([0, sheet_width/2 - chamfer_size, sheet_thickness/2 - chamfer_size]);
    chamfer_cut_y([0, -sheet_width/2 + chamfer_size, sheet_thickness/2 - chamfer_size]);
  }
}

// Final Output
difference() {
  sheet_with_rounded_corners();
  mounting_holes();
  chamfer_edges();
}