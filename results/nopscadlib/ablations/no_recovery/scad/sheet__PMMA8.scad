// Parameters
sheet_length = 100; //[50:200:1]
sheet_width = 100; //[50:200:1]
sheet_thickness = 7.94; //[4:16:0.01]
edge_chamfer_size = 1.5; //[0.5:4:0.1]
edge_fillet_radius = 2; //[0.5:6:0.1]
mount_hole_diameter = 6; //[3:12:0.1]
mount_hole_edge_offset = 12; //[6:30:0.5]
hole_clearance_z = 2; //[1:6:0.5]
rounding_sphere_radius = 0.8; //[0.2:2:0.1]

// Base shapes
module sheet_body() {
  cube([sheet_length, sheet_width, sheet_thickness], center=true);
}

module edge_chamfer() {
  linear_extrude(height=sheet_thickness, center=true) {
    polygon(points=[
      [sheet_length/2, sheet_width/2],
      [sheet_length/2 - edge_chamfer_size, sheet_width/2 - edge_chamfer_size],
      [-sheet_length/2 + edge_chamfer_size, sheet_width/2 - edge_chamfer_size],
      [-sheet_length/2, sheet_width/2]
    ]);
  }
}

module edge_fillet() {
  sphere(r=rounding_sphere_radius, center=true);
}

module mounting_hole_cyl(pos) {
  translate(pos)
    cylinder(r=mount_hole_diameter/2, h=sheet_thickness + hole_clearance_z, center=true);
}

// Operations
module mounting_holes() {
  union() {
    mounting_hole_cyl([sheet_length/2 - mount_hole_edge_offset, sheet_width/2 - mount_hole_edge_offset, 0]);
    mounting_hole_cyl([-sheet_length/2 + mount_hole_edge_offset, sheet_width/2 - mount_hole_edge_offset, 0]);
    mounting_hole_cyl([-sheet_length/2 + mount_hole_edge_offset, -sheet_width/2 + mount_hole_edge_offset, 0]);
    mounting_hole_cyl([sheet_length/2 - mount_hole_edge_offset, -sheet_width/2 + mount_hole_edge_offset, 0]);
  }
}

module sheet_with_chamfer_band() {
  difference() {
    sheet_body();
    edge_chamfer();
  }
}

module sheet_with_edge_fillet() {
  minkowski() {
    sheet_with_chamfer_band();
    edge_fillet();
  }
}

// Final model
module complete_model() {
  difference() {
    sheet_with_edge_fillet();
    mounting_holes();
  }
}

// Render the complete model
color([0.85, 0.85, 0.8]) // Off-white color for the sheet
complete_model();