// Parameters
sheet_length = 200; //[100:400:1]
sheet_width = 200; //[100:400:1]
sheet_thickness = 2; //[1:6:0.5]
corner_radius = 12; //[6:24:1]
hole_diameter = 6; //[3:12:0.5]
hole_edge_margin = 20; //[10:40:1]
chamfer_size = 0.8; //[0.2:2:0.1]
overlap = 1; //[0.5:2:0.5]

// Main sheet body
module sheet_body() {
  color("Silver")
  cube([sheet_length, sheet_width, sheet_thickness], center=true);
}

// Corner cut cylinders
module corner_cut(radius, x, y) {
  translate([x, y, 0])
    cylinder(h=sheet_thickness + 2*overlap, r=radius, center=true);
}

// Corner square cuts
module corner_square(x, y) {
  translate([x, y, 0])
    cube([corner_radius, corner_radius, sheet_thickness + 2*overlap], center=true);
}

// Mounting holes
module hole(x, y) {
  translate([x, y, 0])
    cylinder(h=sheet_thickness + 2*overlap, r=hole_diameter/2, center=true);
}

// Chamfer cuts
module chamfer_cut_x(x) {
  translate([x, 0, 0])
    rotate([0, 45, 0])
      cube([chamfer_size*2, sheet_width + 2*overlap, sheet_thickness + 2*overlap], center=true);
}

module chamfer_cut_y(y) {
  translate([0, y, 0])
    rotate([45, 0, 0])
      cube([sheet_length + 2*overlap, chamfer_size*2, sheet_thickness + 2*overlap], center=true);
}

// Final geometry
difference() {
  union() {
    difference() {
      sheet_body();
      // Remove corner squares
      corner_square(-sheet_length/2 + corner_radius/2, sheet_width/2 - corner_radius/2);
      corner_square(sheet_length/2 - corner_radius/2, sheet_width/2 - corner_radius/2);
      corner_square(-sheet_length/2 + corner_radius/2, -sheet_width/2 + corner_radius/2);
      corner_square(sheet_length/2 - corner_radius/2, -sheet_width/2 + corner_radius/2);
    }
    // Add rounded corners
    corner_cut(corner_radius, -sheet_length/2 + corner_radius, sheet_width/2 - corner_radius);
    corner_cut(corner_radius, sheet_length/2 - corner_radius, sheet_width/2 - corner_radius);
    corner_cut(corner_radius, -sheet_length/2 + corner_radius, -sheet_width/2 + corner_radius);
    corner_cut(corner_radius, sheet_length/2 - corner_radius, -sheet_width/2 + corner_radius);
  }
  // Remove mounting holes
  hole(-sheet_length/2 + hole_edge_margin, sheet_width/2 - hole_edge_margin);
  hole(sheet_length/2 - hole_edge_margin, sheet_width/2 - hole_edge_margin);
  hole(-sheet_length/2 + hole_edge_margin, -sheet_width/2 + hole_edge_margin);
  hole(sheet_length/2 - hole_edge_margin, -sheet_width/2 + hole_edge_margin);
  // Apply chamfers
  chamfer_cut_x(sheet_length/2 - chamfer_size);
  chamfer_cut_x(-sheet_length/2 + chamfer_size);
  chamfer_cut_y(sheet_width/2 - chamfer_size);
  chamfer_cut_y(-sheet_width/2 + chamfer_size);
}