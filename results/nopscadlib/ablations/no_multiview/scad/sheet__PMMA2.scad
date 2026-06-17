// Parameters
sheet_length = 300; //[150:600:1]
sheet_width = 200; //[100:400:1]
sheet_thickness = 3; //[1.5:6:0.1]
corner_radius = 12; //[6:24:0.5]
chamfer_size = 1; //[0.5:2:0.1]
hole_diameter = 6; //[3:12:0.5]
hole_edge_margin = 15; //[8:30:1]
film_thickness = 0.1; //[0.05:0.3:0.01]
overlap = 1; //[0.5:2:0.1]

// Base shapes
module acrylic_sheet_body() {
  cube([sheet_length, sheet_width, sheet_thickness], center=true);
}

module rounded_corners() {
  cube([sheet_length - 2*corner_radius, sheet_width - 2*corner_radius, sheet_thickness], center=true);
}

module corner_cylinder(x, y) {
  translate([x, y, 0])
    cylinder(r=corner_radius, h=sheet_thickness, center=true);
}

module edge_chamfer() {
  cube([sheet_length - 2*chamfer_size, sheet_width - 2*chamfer_size, sheet_thickness + 2*overlap], center=true);
}

module mounting_hole(x, y) {
  translate([x, y, 0])
    cylinder(r=hole_diameter/2, h=sheet_thickness + 2*overlap, center=true);
}

module protective_film_layer() {
  translate([0, 0, sheet_thickness/2 + film_thickness/2 - overlap])
    cube([sheet_length, sheet_width, film_thickness], center=true);
}

// Operations
module rounded_corners_union() {
  union() {
    rounded_corners();
    corner_cylinder(sheet_length/2 - corner_radius, sheet_width/2 - corner_radius);
    corner_cylinder(-sheet_length/2 + corner_radius, sheet_width/2 - corner_radius);
    corner_cylinder(-sheet_length/2 + corner_radius, -sheet_width/2 + corner_radius);
    corner_cylinder(sheet_length/2 - corner_radius, -sheet_width/2 + corner_radius);
  }
}

module sheet_with_rounded_corners() {
  intersection() {
    acrylic_sheet_body();
    rounded_corners_union();
  }
}

module sheet_chamfered() {
  intersection() {
    sheet_with_rounded_corners();
    edge_chamfer();
  }
}

module holes_union() {
  union() {
    mounting_hole(sheet_length/2 - hole_edge_margin, sheet_width/2 - hole_edge_margin);
    mounting_hole(-sheet_length/2 + hole_edge_margin, sheet_width/2 - hole_edge_margin);
    mounting_hole(-sheet_length/2 + hole_edge_margin, -sheet_width/2 + hole_edge_margin);
    mounting_hole(sheet_length/2 - hole_edge_margin, -sheet_width/2 + hole_edge_margin);
  }
}

module sheet_final_acrylic() {
  difference() {
    sheet_chamfered();
    holes_union();
  }
}

// Final model
module complete_model() {
  union() {
    color([0.85, 0.85, 0.8]) sheet_final_acrylic(); // Acrylic sheet
    color([0.9, 0.9, 0.9, 0.5]) protective_film_layer(); // Protective film
  }
}

// Render the complete model
complete_model();