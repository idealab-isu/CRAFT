// Parameters
sheet_length = 200; //[100:400:1]
sheet_width = 150; //[75:300:1]
sheet_thickness = 2; //[1:6:0.5]
corner_radius = 10; //[5:25:1]
hole_diameter = 6; //[3:12:0.5]
edge_margin = 15; //[8:40:1]
chamfer_size = 0.8; //[0.2:2:0.1]
eps = 1; //[0.5:2:0.1]

// Base Shapes
module sheet_body() {
  translate([0, 0, 0])
    cube([sheet_length, sheet_width, sheet_thickness], center=true);
}

module corner_cut(radius, position) {
  translate(position)
    cylinder(h=sheet_thickness + 2*eps, r=radius, center=true);
}

module corner_square(size, position) {
  translate(position)
    cube([size, size, sheet_thickness + 2*eps], center=true);
}

module hole(radius, position) {
  translate(position)
    cylinder(h=sheet_thickness + 2*eps, r=radius, center=true);
}

module chamfer_kernel() {
  sphere(r=chamfer_size, center=true);
}

// Operations
module rounded_corners() {
  difference() {
    sheet_body();
    corner_square(corner_radius, [-sheet_length/2 + corner_radius/2, sheet_width/2 - corner_radius/2, 0]);
    corner_square(corner_radius, [sheet_length/2 - corner_radius/2, sheet_width/2 - corner_radius/2, 0]);
    corner_square(corner_radius, [-sheet_length/2 + corner_radius/2, -sheet_width/2 + corner_radius/2, 0]);
    corner_square(corner_radius, [sheet_length/2 - corner_radius/2, -sheet_width/2 + corner_radius/2, 0]);
  }
}

module rounded_corners_2() {
  union() {
    rounded_corners();
    corner_cut(corner_radius, [-sheet_length/2 + corner_radius, sheet_width/2 - corner_radius, 0]);
    corner_cut(corner_radius, [sheet_length/2 - corner_radius, sheet_width/2 - corner_radius, 0]);
    corner_cut(corner_radius, [-sheet_length/2 + corner_radius, -sheet_width/2 + corner_radius, 0]);
    corner_cut(corner_radius, [sheet_length/2 - corner_radius, -sheet_width/2 + corner_radius, 0]);
  }
}

module mounting_holes() {
  difference() {
    rounded_corners_2();
    hole(hole_diameter/2, [-sheet_length/2 + edge_margin, sheet_width/2 - edge_margin, 0]);
    hole(hole_diameter/2, [sheet_length/2 - edge_margin, sheet_width/2 - edge_margin, 0]);
    hole(hole_diameter/2, [-sheet_length/2 + edge_margin, -sheet_width/2 + edge_margin, 0]);
    hole(hole_diameter/2, [sheet_length/2 - edge_margin, -sheet_width/2 + edge_margin, 0]);
  }
}

module chamfer_edges() {
  minkowski() {
    mounting_holes();
    chamfer_kernel();
  }
}

// Final Output
chamfer_edges();