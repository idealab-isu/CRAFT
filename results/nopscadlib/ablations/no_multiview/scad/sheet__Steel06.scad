// Parameters
sheet_length = 300; //[150:600:1]
sheet_width = 200; //[100:400:1]
sheet_thickness = 3; //[1.5:6:0.5]
corner_chamfer = 10; //[5:20:1]
corner_round_radius = 6; //[3:12:1]
hole_diameter = 8; //[4:16:0.5]
hole_edge_offset_x = 25; //[12.5:50:1]
hole_edge_offset_y = 20; //[10:40:1]
overlap = 1; //[0.5:2:0.5]

// Base Shapes
module sheet_plate() {
  cube([sheet_length, sheet_width, sheet_thickness], center=true);
}

module corner_chamfer(position) {
  rotate([0, 0, 45])
    translate(position)
      cube([corner_chamfer*2, corner_chamfer*2, sheet_thickness + overlap*2], center=true);
}

module corner_round(position) {
  translate(position)
    cylinder(r=corner_round_radius, h=sheet_thickness + overlap*2, center=true);
}

module mounting_hole(position) {
  translate(position)
    cylinder(r=hole_diameter/2, h=sheet_thickness + overlap*2, center=true);
}

// Operations
module corner_chamfers() {
  union() {
    corner_chamfer([sheet_length/2 - corner_chamfer + overlap, sheet_width/2 - corner_chamfer + overlap, 0]);
    corner_chamfer([-sheet_length/2 + corner_chamfer - overlap, sheet_width/2 - corner_chamfer + overlap, 0]);
    corner_chamfer([-sheet_length/2 + corner_chamfer - overlap, -sheet_width/2 + corner_chamfer - overlap, 0]);
    corner_chamfer([sheet_length/2 - corner_chamfer + overlap, -sheet_width/2 + corner_chamfer - overlap, 0]);
  }
}

module corner_rounds() {
  union() {
    corner_round([sheet_length/2 - corner_chamfer + corner_round_radius, sheet_width/2 - corner_chamfer + corner_round_radius, 0]);
    corner_round([-sheet_length/2 + corner_chamfer - corner_round_radius, sheet_width/2 - corner_chamfer + corner_round_radius, 0]);
    corner_round([-sheet_length/2 + corner_chamfer - corner_round_radius, -sheet_width/2 + corner_chamfer - corner_round_radius, 0]);
    corner_round([sheet_length/2 - corner_chamfer + corner_round_radius, -sheet_width/2 + corner_chamfer - corner_round_radius, 0]);
  }
}

module mounting_holes() {
  union() {
    mounting_hole([sheet_length/2 - hole_edge_offset_x, sheet_width/2 - hole_edge_offset_y, 0]);
    mounting_hole([-sheet_length/2 + hole_edge_offset_x, sheet_width/2 - hole_edge_offset_y, 0]);
    mounting_hole([-sheet_length/2 + hole_edge_offset_x, -sheet_width/2 + hole_edge_offset_y, 0]);
    mounting_hole([sheet_length/2 - hole_edge_offset_x, -sheet_width/2 + hole_edge_offset_y, 0]);
  }
}

// Final Model
difference() {
  difference() {
    difference() {
      sheet_plate();
      corner_chamfers();
    }
    corner_rounds();
  }
  mounting_holes();
}