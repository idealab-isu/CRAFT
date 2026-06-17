// Parameters
sheet_length = 300; //[150:600:1]
sheet_width = 200; //[100:400:1]
sheet_thickness = 3; //[1.5:6:0.5]
corner_radius = 12; //[6:24:1]
chamfer_size = 6; //[3:12:1]
hole_diameter = 8; //[4:16:1]
hole_edge_offset = 20; //[10:40:1]
cut_overlap = 1; //[0.5:2:0.5]

// Base Shapes
module sheet_body() {
  translate([0, 0, 0])
    cube([sheet_length, sheet_width, sheet_thickness], center=true);
}

module rounded_corner_cutter(position) {
  translate(position)
    cylinder(r=corner_radius, h=sheet_thickness + 2*cut_overlap, center=true);
}

module rounded_corner_square(position) {
  translate(position)
    cube([corner_radius + cut_overlap, corner_radius + cut_overlap, sheet_thickness + 2*cut_overlap], center=true);
}

module chamfer_cutter(position) {
  translate(position)
    rotate([0, 0, 45])
      cube([chamfer_size, chamfer_size, sheet_thickness + 2*cut_overlap], center=true);
}

module mounting_hole(position) {
  translate(position)
    cylinder(r=hole_diameter/2, h=sheet_thickness + 2*cut_overlap, center=true);
}

// Operations
module rounded_corners() {
  union() {
    difference() {
      rounded_corner_square([sheet_length/2 - (corner_radius + cut_overlap)/2, sheet_width/2 - (corner_radius + cut_overlap)/2, 0]);
      rounded_corner_cutter([sheet_length/2 - corner_radius, sheet_width/2 - corner_radius, 0]);
    }
    difference() {
      rounded_corner_square([-sheet_length/2 + (corner_radius + cut_overlap)/2, sheet_width/2 - (corner_radius + cut_overlap)/2, 0]);
      rounded_corner_cutter([-sheet_length/2 + corner_radius, sheet_width/2 - corner_radius, 0]);
    }
    difference() {
      rounded_corner_square([sheet_length/2 - (corner_radius + cut_overlap)/2, -sheet_width/2 + (corner_radius + cut_overlap)/2, 0]);
      rounded_corner_cutter([sheet_length/2 - corner_radius, -sheet_width/2 + corner_radius, 0]);
    }
    difference() {
      rounded_corner_square([-sheet_length/2 + (corner_radius + cut_overlap)/2, -sheet_width/2 + (corner_radius + cut_overlap)/2, 0]);
      rounded_corner_cutter([-sheet_length/2 + corner_radius, -sheet_width/2 + corner_radius, 0]);
    }
  }
}

module corner_chamfers() {
  union() {
    chamfer_cutter([sheet_length/2 - chamfer_size/2, sheet_width/2 - chamfer_size/2, 0]);
    chamfer_cutter([-sheet_length/2 + chamfer_size/2, sheet_width/2 - chamfer_size/2, 0]);
    chamfer_cutter([sheet_length/2 - chamfer_size/2, -sheet_width/2 + chamfer_size/2, 0]);
    chamfer_cutter([-sheet_length/2 + chamfer_size/2, -sheet_width/2 + chamfer_size/2, 0]);
  }
}

module mounting_holes() {
  union() {
    mounting_hole([sheet_length/2 - hole_edge_offset, sheet_width/2 - hole_edge_offset, 0]);
    mounting_hole([-sheet_length/2 + hole_edge_offset, sheet_width/2 - hole_edge_offset, 0]);
    mounting_hole([sheet_length/2 - hole_edge_offset, -sheet_width/2 + hole_edge_offset, 0]);
    mounting_hole([-sheet_length/2 + hole_edge_offset, -sheet_width/2 + hole_edge_offset, 0]);
  }
}

// Final Model
module complete_model() {
  difference() {
    difference() {
      difference() {
        sheet_body();
        rounded_corners();
      }
      corner_chamfers();
    }
    mounting_holes();
  }
}

// Render the complete model
color("DimGray") complete_model();