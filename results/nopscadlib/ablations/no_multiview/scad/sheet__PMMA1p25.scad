// Parameters
sheet_length = 300; //[150:600:1]
sheet_width = 200; //[100:400:1]
sheet_thickness = 3; //[1.5:6:0.5]
corner_radius = 12; //[6:24:1]
chamfer_size = 1; //[0.5:3:0.5]
hole_diameter = 6; //[3:12:0.5]
hole_edge_offset = 20; //[10:40:1]
film_thickness = 0.2; //[0.05:0.5:0.05]
overlap = 1; //[0.5:2:0.5]

// Base shapes
module acrylic_sheet() {
  cube([sheet_length, sheet_width, sheet_thickness], center=true);
}

module rounded_corner_cyl(pos) {
  translate(pos)
    cylinder(r=corner_radius, h=sheet_thickness + 2*overlap, center=true);
}

module rounded_corner_cut(pos) {
  translate(pos)
    cube([corner_radius, corner_radius, sheet_thickness + 2*overlap], center=true);
}

module chamfer_inset(z_pos) {
  translate([0, 0, z_pos])
    cube([sheet_length - 2*chamfer_size, sheet_width - 2*chamfer_size, sheet_thickness + 2*overlap], center=true);
}

module mounting_hole(pos) {
  translate(pos)
    cylinder(r=hole_diameter/2, h=sheet_thickness + 2*overlap, center=true);
}

module protective_film_layer() {
  translate([0, 0, sheet_thickness/2 + film_thickness/2 - overlap])
    cube([sheet_length, sheet_width, film_thickness], center=true);
}

// Operations
module rounded_corners() {
  union() {
    intersection() {
      rounded_corner_cyl([sheet_length/2 - corner_radius, sheet_width/2 - corner_radius, 0]);
      rounded_corner_cut([sheet_length/2 - corner_radius/2, sheet_width/2 - corner_radius/2, 0]);
    }
    intersection() {
      rounded_corner_cyl([-sheet_length/2 + corner_radius, sheet_width/2 - corner_radius, 0]);
      rounded_corner_cut([-sheet_length/2 + corner_radius/2, sheet_width/2 - corner_radius/2, 0]);
    }
    intersection() {
      rounded_corner_cyl([-sheet_length/2 + corner_radius, -sheet_width/2 + corner_radius, 0]);
      rounded_corner_cut([-sheet_length/2 + corner_radius/2, -sheet_width/2 + corner_radius/2, 0]);
    }
    intersection() {
      rounded_corner_cyl([sheet_length/2 - corner_radius, -sheet_width/2 + corner_radius, 0]);
      rounded_corner_cut([sheet_length/2 - corner_radius/2, -sheet_width/2 + corner_radius/2, 0]);
    }
  }
}

module sheet_with_rounded_corners() {
  union() {
    acrylic_sheet();
    rounded_corners();
  }
}

module chamfered_edges() {
  difference() {
    sheet_with_rounded_corners();
    chamfer_inset(sheet_thickness/2 + (sheet_thickness + 2*overlap)/2 - overlap);
    chamfer_inset(-sheet_thickness/2 - (sheet_thickness + 2*overlap)/2 + overlap);
  }
}

module mounting_holes() {
  difference() {
    chamfered_edges();
    mounting_hole([sheet_length/2 - hole_edge_offset, sheet_width/2 - hole_edge_offset, 0]);
    mounting_hole([-sheet_length/2 + hole_edge_offset, sheet_width/2 - hole_edge_offset, 0]);
    mounting_hole([-sheet_length/2 + hole_edge_offset, -sheet_width/2 + hole_edge_offset, 0]);
    mounting_hole([sheet_length/2 - hole_edge_offset, -sheet_width/2 + hole_edge_offset, 0]);
  }
}

// Final model
module complete_model() {
  union() {
    mounting_holes();
    protective_film_layer();
  }
}

// Render the complete model
color([0.85, 0.85, 0.8]) complete_model();