// Parameters
sheet_length = 300; //[150:600:1]
sheet_width = 200; //[100:400:1]
sheet_thickness = 2; //[1:6:0.5]
corner_radius = 12; //[6:24:1]
chamfer_size = 0.6; //[0.2:2:0.1]
overlap = 1; //[0.5:2:0.1]

// Base Shapes
module sheet_body() {
  translate([0, 0, 0])
    cube([sheet_length, sheet_width, sheet_thickness], center=true);
}

module corner_cut(radius, x, y) {
  translate([x, y, 0])
    cylinder(h=sheet_thickness + 2*overlap, r=radius, center=true);
}

module corner_square(x, y) {
  translate([x, y, 0])
    cube([corner_radius + overlap, corner_radius + overlap, sheet_thickness + 2*overlap], center=true);
}

module chamfer_cut_x(x) {
  translate([x, 0, sheet_thickness/2 - chamfer_size])
    rotate([0, 45, 0])
      cube([chamfer_size*2, sheet_width + 2*overlap, chamfer_size*2], center=true);
}

module chamfer_cut_y(y) {
  translate([0, y, sheet_thickness/2 - chamfer_size])
    rotate([45, 0, 0])
      cube([sheet_length + 2*overlap, chamfer_size*2, chamfer_size*2], center=true);
}

// Operations
module rounded_corners() {
  difference() {
    sheet_body();
    corner_square(-sheet_length/2 + (corner_radius + overlap)/2, sheet_width/2 - (corner_radius + overlap)/2);
    corner_square(sheet_length/2 - (corner_radius + overlap)/2, sheet_width/2 - (corner_radius + overlap)/2);
    corner_square(-sheet_length/2 + (corner_radius + overlap)/2, -sheet_width/2 + (corner_radius + overlap)/2);
    corner_square(sheet_length/2 - (corner_radius + overlap)/2, -sheet_width/2 + (corner_radius + overlap)/2);
    corner_cut(corner_radius, -sheet_length/2 + corner_radius, sheet_width/2 - corner_radius);
    corner_cut(corner_radius, sheet_length/2 - corner_radius, sheet_width/2 - corner_radius);
    corner_cut(corner_radius, -sheet_length/2 + corner_radius, -sheet_width/2 + corner_radius);
    corner_cut(corner_radius, sheet_length/2 - corner_radius, -sheet_width/2 + corner_radius);
  }
}

module edge_chamfer() {
  difference() {
    rounded_corners();
    chamfer_cut_x(sheet_length/2 - chamfer_size);
    chamfer_cut_x(-sheet_length/2 + chamfer_size);
    chamfer_cut_y(sheet_width/2 - chamfer_size);
    chamfer_cut_y(-sheet_width/2 + chamfer_size);
  }
}

// Final Output
module complete_model() {
  union() {
    edge_chamfer();
  }
}

// Render the complete model
color("Silver") complete_model();