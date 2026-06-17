// Parameters
cell_height = 50.0; //[25.0:100.0:0.1]
cell_diameter = 26.2; //[13.1:52.4:0.1]
overlap = 1.0; //[0.5:2.0:0.1]
face_thickness = 0.8; //[0.4:2.0:0.1]
terminal_diameter = 8.0; //[4.0:16.0:0.1]
terminal_height = 1.6; //[0.8:4.0:0.1]
insulator_outer_diameter = 18.0; //[9.0:30.0:0.1]
insulator_inner_diameter = 10.0; //[5.0:20.0:0.1]
insulator_thickness = 0.6; //[0.3:2.0:0.1]
fillet_radius = 0.8; //[0.4:2.5:0.1]
label_thickness = 0.25; //[0.1:0.8:0.05]
label_height = 44.0; //[20.0:90.0:0.5]
label_clearance = 0.2; //[0.0:1.0:0.05]

// Base Shapes
module cell_body() {
  color("DimGray")
  cylinder(h=cell_height, r=cell_diameter/2, center=true);
}

module top_face() {
  color("Silver")
  translate([0, 0, cell_height/2 - face_thickness/2 + overlap/2])
    cylinder(h=face_thickness, r=cell_diameter/2, center=true);
}

module bottom_face() {
  color("Silver")
  translate([0, 0, -cell_height/2 + face_thickness/2 - overlap/2])
    cylinder(h=face_thickness, r=cell_diameter/2, center=true);
}

module positive_terminal_button() {
  color("Silver")
  translate([0, 0, cell_height/2 + terminal_height/2 - overlap])
    cylinder(h=terminal_height, r=terminal_diameter/2, center=true);
}

module insulator_outer_disc() {
  translate([0, 0, cell_height/2 + insulator_thickness/2 - overlap])
    cylinder(h=insulator_thickness, r=insulator_outer_diameter/2, center=true);
}

module insulator_inner_hole() {
  translate([0, 0, cell_height/2 + insulator_thickness/2 - overlap])
    cylinder(h=insulator_thickness + 2*overlap, r=insulator_inner_diameter/2, center=true);
}

module label_outer_sleeve() {
  color("Blue")
  cylinder(h=label_height, r=cell_diameter/2 + label_clearance + label_thickness, center=true);
}

module label_inner_void() {
  cylinder(h=label_height + 2*overlap, r=cell_diameter/2 + label_clearance, center=true);
}

module fillet_sphere() {
  sphere(r=fillet_radius);
}

// Operations
module top_insulator_ring() {
  difference() {
    insulator_outer_disc();
    insulator_inner_hole();
  }
}

module label_wrap() {
  difference() {
    label_outer_sleeve();
    label_inner_void();
  }
}

module cell_core_union() {
  union() {
    cell_body();
    top_face();
    bottom_face();
    positive_terminal_button();
    top_insulator_ring();
  }
}

module cell_with_label_union() {
  union() {
    cell_core_union();
    label_wrap();
  }
}

// Final Output
minkowski() {
  cell_with_label_union();
  fillet_sphere();
}