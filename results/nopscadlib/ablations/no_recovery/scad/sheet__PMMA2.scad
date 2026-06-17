// Parameters
sheet_length = 300; //[150:600:1]
sheet_width = 200; //[100:400:1]
sheet_thickness = 3; //[1.5:6:0.5]
corner_radius = 12; //[6:24:1]
hole_diameter = 6; //[3:12:0.5]
hole_edge_offset = 20; //[10:40:1]
chamfer_size = 1; //[0.5:3:0.25]
overlap = 1; //[0.5:2:0.5]

// Base shapes
module acrylic_sheet() {
  cube([sheet_length, sheet_width, sheet_thickness], center=true);
}

module corner_rounding_cyl() {
  cylinder(r=corner_radius, h=sheet_thickness + 2*overlap, center=true);
}

module corner_rounding_box() {
  cube([corner_radius, corner_radius, sheet_thickness + 2*overlap], center=true);
}

module mounting_hole_cyl() {
  cylinder(r=hole_diameter/2, h=sheet_thickness + 2*overlap, center=true);
}

module edge_chamfer_wedge_x() {
  cube([chamfer_size, sheet_width + 2*overlap, chamfer_size], center=true);
}

module edge_chamfer_wedge_y() {
  cube([sheet_length + 2*overlap, chamfer_size, chamfer_size], center=true);
}

// Corner rounding
module corner_rounding() {
  union() {
    translate([-sheet_length/2 + corner_radius/2, sheet_width/2 - corner_radius/2, 0])
      difference() {
        corner_rounding_box();
        translate([corner_radius/2, -corner_radius/2, 0]) corner_rounding_cyl();
      }
    translate([sheet_length/2 - corner_radius/2, sheet_width/2 - corner_radius/2, 0])
      difference() {
        corner_rounding_box();
        translate([-corner_radius/2, -corner_radius/2, 0]) corner_rounding_cyl();
      }
    translate([-sheet_length/2 + corner_radius/2, -sheet_width/2 + corner_radius/2, 0])
      difference() {
        corner_rounding_box();
        translate([corner_radius/2, corner_radius/2, 0]) corner_rounding_cyl();
      }
    translate([sheet_length/2 - corner_radius/2, -sheet_width/2 + corner_radius/2, 0])
      difference() {
        corner_rounding_box();
        translate([-corner_radius/2, corner_radius/2, 0]) corner_rounding_cyl();
      }
  }
}

// Mounting holes
module mounting_holes() {
  union() {
    translate([-sheet_length/2 + hole_edge_offset, sheet_width/2 - hole_edge_offset, 0])
      mounting_hole_cyl();
    translate([sheet_length/2 - hole_edge_offset, sheet_width/2 - hole_edge_offset, 0])
      mounting_hole_cyl();
    translate([-sheet_length/2 + hole_edge_offset, -sheet_width/2 + hole_edge_offset, 0])
      mounting_hole_cyl();
    translate([sheet_length/2 - hole_edge_offset, -sheet_width/2 + hole_edge_offset, 0])
      mounting_hole_cyl();
  }
}

// Edge chamfer
module edge_chamfer() {
  union() {
    translate([sheet_length/2 - chamfer_size/2, 0, sheet_thickness/2 - chamfer_size/2])
      edge_chamfer_wedge_x();
    translate([-sheet_length/2 + chamfer_size/2, 0, sheet_thickness/2 - chamfer_size/2])
      edge_chamfer_wedge_x();
    translate([0, sheet_width/2 - chamfer_size/2, sheet_thickness/2 - chamfer_size/2])
      edge_chamfer_wedge_y();
    translate([0, -sheet_width/2 + chamfer_size/2, sheet_thickness/2 - chamfer_size/2])
      edge_chamfer_wedge_y();
  }
}

// Final sheet with all features
module sheet_final() {
  difference() {
    difference() {
      difference() {
        acrylic_sheet();
        corner_rounding();
      }
      mounting_holes();
    }
    edge_chamfer();
  }
}

// Render the final sheet
color([0.85, 0.85, 0.8]) sheet_final();