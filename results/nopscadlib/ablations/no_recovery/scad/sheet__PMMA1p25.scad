// Parameters
sheet_length = 300; //[150:600:1]
sheet_width = 200; //[100:400:1]
sheet_thickness = 3; //[1.5:6:0.5]
corner_radius = 12; //[6:24:1]
chamfer_size = 1; //[0.5:3:0.5]
hole_diameter = 6; //[3:12:0.5]
hole_edge_margin = 20; //[10:40:1]
hole_clearance_z = 1; //[0.5:3:0.5]
overlap = 1; //[0.5:2:0.5]

// Base shapes
module acrylic_sheet_body() {
  cube([sheet_length, sheet_width, sheet_thickness], center = true);
}

module rounded_corner_cut_cyl() {
  cylinder(r = corner_radius, h = sheet_thickness + 2 * overlap, center = true);
}

module rounded_corner_cut_box() {
  cube([corner_radius, corner_radius, sheet_thickness + 2 * overlap], center = true);
}

module mounting_hole_cyl() {
  cylinder(r = hole_diameter / 2, h = sheet_thickness + 2 * hole_clearance_z, center = true);
}

module edge_chamfer_wedge_x() {
  rotate([0, 45, 0])
    cube([chamfer_size, sheet_width + 2 * overlap, chamfer_size], center = true);
}

module edge_chamfer_wedge_y() {
  rotate([45, 0, 0])
    cube([sheet_length + 2 * overlap, chamfer_size, chamfer_size], center = true);
}

// Operations
module rounded_corners() {
  union() {
    translate([-sheet_length / 2 + corner_radius / 2, sheet_width / 2 - corner_radius / 2, 0])
      difference() {
        rounded_corner_cut_box();
        translate([-sheet_length / 2 + corner_radius, sheet_width / 2 - corner_radius, 0])
          rounded_corner_cut_cyl();
      }
    translate([sheet_length / 2 - corner_radius / 2, sheet_width / 2 - corner_radius / 2, 0])
      difference() {
        rounded_corner_cut_box();
        translate([sheet_length / 2 - corner_radius, sheet_width / 2 - corner_radius, 0])
          rounded_corner_cut_cyl();
      }
    translate([-sheet_length / 2 + corner_radius / 2, -sheet_width / 2 + corner_radius / 2, 0])
      difference() {
        rounded_corner_cut_box();
        translate([-sheet_length / 2 + corner_radius, -sheet_width / 2 + corner_radius, 0])
          rounded_corner_cut_cyl();
      }
    translate([sheet_length / 2 - corner_radius / 2, -sheet_width / 2 + corner_radius / 2, 0])
      difference() {
        rounded_corner_cut_box();
        translate([sheet_length / 2 - corner_radius, -sheet_width / 2 + corner_radius, 0])
          rounded_corner_cut_cyl();
      }
  }
}

module mounting_holes() {
  union() {
    translate([-sheet_length / 2 + hole_edge_margin, sheet_width / 2 - hole_edge_margin, 0])
      mounting_hole_cyl();
    translate([sheet_length / 2 - hole_edge_margin, sheet_width / 2 - hole_edge_margin, 0])
      mounting_hole_cyl();
    translate([-sheet_length / 2 + hole_edge_margin, -sheet_width / 2 + hole_edge_margin, 0])
      mounting_hole_cyl();
    translate([sheet_length / 2 - hole_edge_margin, -sheet_width / 2 + hole_edge_margin, 0])
      mounting_hole_cyl();
  }
}

module edge_chamfer() {
  union() {
    translate([sheet_length / 2 - chamfer_size / 2 + overlap, 0, sheet_thickness / 2 - chamfer_size / 2 + overlap])
      edge_chamfer_wedge_x();
    translate([-sheet_length / 2 + chamfer_size / 2 - overlap, 0, sheet_thickness / 2 - chamfer_size / 2 + overlap])
      edge_chamfer_wedge_x();
    translate([0, sheet_width / 2 - chamfer_size / 2 + overlap, sheet_thickness / 2 - chamfer_size / 2 + overlap])
      edge_chamfer_wedge_y();
    translate([0, -sheet_width / 2 + chamfer_size / 2 - overlap, sheet_thickness / 2 - chamfer_size / 2 + overlap])
      edge_chamfer_wedge_y();
  }
}

// Final model
difference() {
  difference() {
    difference() {
      acrylic_sheet_body();
      rounded_corners();
    }
    mounting_holes();
  }
  edge_chamfer();
}