// Parameters
sheet_length = 300; //[150:600:1]
sheet_width = 200; //[100:400:1]
sheet_thickness = 3; //[1.5:6:0.5]
corner_radius = 15; //[7.5:30:0.5]
chamfer_size = 1; //[0.5:2:0.1]
hole_diameter = 6; //[3:12:0.5]
hole_edge_offset = 20; //[10:40:1]
hole_clearance_z = 2; //[1:5:0.5]

// Base shapes
module acrylic_sheet() {
  cube([sheet_length, sheet_width, sheet_thickness], center=true);
}

module rounded_corners() {
  sphere(r=corner_radius, center=true);
}

module edge_chamfer() {
  sphere(r=chamfer_size, center=true);
}

module mounting_hole(position) {
  translate(position)
    cylinder(h=sheet_thickness + hole_clearance_z, r=hole_diameter/2, center=true);
}

// Operations
module sheet_with_rounded_corners() {
  minkowski() {
    acrylic_sheet();
    rounded_corners();
  }
}

module sheet_with_edge_chamfer() {
  minkowski() {
    sheet_with_rounded_corners();
    edge_chamfer();
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

// Final output
difference() {
  sheet_with_edge_chamfer();
  mounting_holes();
}