// Parameters
cell_height = 70.2; //[35.1:140.4:0.1]
cell_diameter = 32.4; //[16.2:64.8:0.1]
cap_height = 1.0; //[0.5:2.0:0.1]
cap_lip_depth = 0.3; //[0.15:0.6:0.05]
overlap = 0.8; //[0.5:2.0:0.1]
button_diameter = 10.0; //[5.0:20.0:0.1]
button_height = 1.6; //[0.8:3.2:0.1]
insulator_outer_diameter = 18.0; //[9.0:36.0:0.1]
insulator_thickness = 0.6; //[0.3:1.2:0.05]
insulator_height = 0.4; //[0.2:1.0:0.05]
label_thickness = 0.2; //[0.1:0.6:0.05]
label_height = 66.0; //[33.0:132.0:0.1]
edge_chamfer = 0.6; //[0.3:1.5:0.1]

// Base Shapes
module cell_body() {
  color("DimGray")
  cylinder(h = cell_height - 2 * cap_height, r = cell_diameter / 2, center = true);
}

module top_cap_main() {
  cylinder(h = cap_height + overlap, r = cell_diameter / 2, center = true);
}

module top_cap_lip() {
  cylinder(h = cap_height + overlap, r = cell_diameter / 2 - cap_lip_depth, center = true);
}

module bottom_cap_main() {
  cylinder(h = cap_height + overlap, r = cell_diameter / 2, center = true);
}

module bottom_cap_lip() {
  cylinder(h = cap_height + overlap, r = cell_diameter / 2 - cap_lip_depth, center = true);
}

module positive_terminal_button() {
  color("Silver")
  cylinder(h = button_height, r = button_diameter / 2, center = true);
}

module insulator_ring_outer() {
  color("Black")
  cylinder(h = insulator_height, r = insulator_outer_diameter / 2, center = true);
}

module insulator_ring_inner_cut() {
  cylinder(h = insulator_height + 2 * overlap, r = insulator_outer_diameter / 2 - insulator_thickness, center = true);
}

module label_wrap() {
  color("LightGray")
  cylinder(h = label_height, r = cell_diameter / 2 + label_thickness, center = true);
}

module chamfer_cut_top() {
  rotate([180, 0, 0])
  cylinder(h = edge_chamfer, r1 = cell_diameter / 2 + label_thickness + edge_chamfer, r2 = 0, center = true);
}

module chamfer_cut_bottom() {
  cylinder(h = edge_chamfer, r1 = cell_diameter / 2 + label_thickness + edge_chamfer, r2 = 0, center = true);
}

// Operations
module top_cap() {
  difference() {
    top_cap_main();
    top_cap_lip();
  }
}

module bottom_cap() {
  difference() {
    bottom_cap_main();
    bottom_cap_lip();
  }
}

module insulator_ring() {
  difference() {
    insulator_ring_outer();
    insulator_ring_inner_cut();
  }
}

module battery_raw_union() {
  union() {
    cell_body();
    translate([0, 0, (cell_height - 2 * cap_height) / 2 + (cap_height + overlap) / 2 - overlap]) top_cap();
    translate([0, 0, -(cell_height - 2 * cap_height) / 2 - (cap_height + overlap) / 2 + overlap]) bottom_cap();
    translate([0, 0, cell_height / 2 - cap_height + button_height / 2 - overlap]) positive_terminal_button();
    translate([0, 0, cell_height / 2 - cap_height + insulator_height / 2 - overlap]) insulator_ring();
    label_wrap();
  }
}

module edge_fillets_chamfers() {
  difference() {
    battery_raw_union();
    translate([0, 0, cell_height / 2 - edge_chamfer / 2]) chamfer_cut_top();
    translate([0, 0, -cell_height / 2 + edge_chamfer / 2]) chamfer_cut_bottom();
  }
}

// Final Output
edge_fillets_chamfers();