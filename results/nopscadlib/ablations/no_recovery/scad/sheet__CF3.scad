// Parameters
sheet_length = 200; //[100:400:1]
sheet_width = 150; //[75:300:1]
sheet_thickness = 2; //[1:6:0.5]
chamfer_size = 0.5; //[0:2:0.1]
corner_radius = 5; //[0:20:0.5]
mount_hole_diameter = 6; //[2:12:0.5]
mount_hole_edge_offset = 15; //[5:40:1]
hole_clearance_z = 1; //[0.2:3:0.1]
overlap = 1; //[0.5:2:0.1]

// Base Shapes
module sheet_plate() {
  linear_extrude(height = sheet_thickness, center = true) {
    polygon(points = [
      [sheet_length/2 - corner_radius, sheet_width/2],
      [-sheet_length/2 + corner_radius, sheet_width/2],
      [-sheet_length/2, sheet_width/2 - corner_radius],
      [-sheet_length/2, -sheet_width/2 + corner_radius],
      [-sheet_length/2 + corner_radius, -sheet_width/2],
      [sheet_length/2 - corner_radius, -sheet_width/2],
      [sheet_length/2, -sheet_width/2 + corner_radius],
      [sheet_length/2, sheet_width/2 - corner_radius]
    ]);
  }
}

module corner_radius_cyl(pos) {
  translate(pos)
    cylinder(r = corner_radius, h = sheet_thickness, center = true);
}

module edge_chamfer_top() {
  translate([0, 0, sheet_thickness/2 - chamfer_size/2])
    linear_extrude(height = chamfer_size, center = true) {
      polygon(points = [
        [sheet_length/2 - chamfer_size - corner_radius, sheet_width/2 - chamfer_size],
        [-sheet_length/2 + chamfer_size + corner_radius, sheet_width/2 - chamfer_size],
        [-sheet_length/2 + chamfer_size, sheet_width/2 - chamfer_size - corner_radius],
        [-sheet_length/2 + chamfer_size, -sheet_width/2 + chamfer_size + corner_radius],
        [-sheet_length/2 + chamfer_size + corner_radius, -sheet_width/2 + chamfer_size],
        [sheet_length/2 - chamfer_size - corner_radius, -sheet_width/2 + chamfer_size],
        [sheet_length/2 - chamfer_size, -sheet_width/2 + chamfer_size + corner_radius],
        [sheet_length/2 - chamfer_size, sheet_width/2 - chamfer_size - corner_radius]
      ]);
    }
}

module mounting_hole(pos) {
  translate(pos)
    cylinder(r = mount_hole_diameter/2, h = sheet_thickness + hole_clearance_z, center = true);
}

// Operations
module complete_model() {
  difference() {
    union() {
      union() {
        sheet_plate();
        corner_radius_cyl([sheet_length/2 - corner_radius, sheet_width/2 - corner_radius, 0]);
        corner_radius_cyl([-sheet_length/2 + corner_radius, sheet_width/2 - corner_radius, 0]);
        corner_radius_cyl([-sheet_length/2 + corner_radius, -sheet_width/2 + corner_radius, 0]);
        corner_radius_cyl([sheet_length/2 - corner_radius, -sheet_width/2 + corner_radius, 0]);
      }
      edge_chamfer_top();
    }
    mounting_hole([-sheet_length/2 + mount_hole_edge_offset, -sheet_width/2 + mount_hole_edge_offset, 0]);
    mounting_hole([sheet_length/2 - mount_hole_edge_offset, -sheet_width/2 + mount_hole_edge_offset, 0]);
    mounting_hole([sheet_length/2 - mount_hole_edge_offset, sheet_width/2 - mount_hole_edge_offset, 0]);
    mounting_hole([-sheet_length/2 + mount_hole_edge_offset, sheet_width/2 - mount_hole_edge_offset, 0]);
  }
}

// Final Output
color([0.1, 0.1, 0.1]) // Carbon-fiber sheet color
complete_model();