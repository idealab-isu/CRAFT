// Parameters
cell_height = 44.5; //[22.25:89:0.1]
cell_diameter = 10.5; //[5.25:21:0.1]
cap_height = 0.8; //[0.4:1.6:0.05]
cap_diameter = 10.5; //[5.25:21:0.1]
button_height = 1.2; //[0.6:2.4:0.05]
button_diameter = 4.5; //[2.25:9:0.1]
insulator_thickness = 0.3; //[0.15:0.6:0.05]
insulator_height = 0.4; //[0.2:0.8:0.05]
label_thickness = 0.2; //[0.1:0.4:0.05]
label_height = 40; //[20:80:0.5]
fillet_radius = 0.6; //[0.3:1.2:0.05]
overlap = 0.8; //[0.5:2:0.1]

// Base Shapes
module cell_body() {
  color("DimGray")
  cylinder(h = cell_height - 2 * cap_height, r = cell_diameter / 2, center = true);
}

module top_cap() {
  color("Silver")
  translate([0, 0, (cell_height - cap_height) / 2 - overlap / 2])
  cylinder(h = cap_height, r = cap_diameter / 2, center = true);
}

module bottom_cap() {
  color("Silver")
  translate([0, 0, -(cell_height - cap_height) / 2 + overlap / 2])
  cylinder(h = cap_height, r = cap_diameter / 2, center = true);
}

module positive_terminal_button() {
  color("Gold")
  translate([0, 0, cell_height / 2 - cap_height - button_height / 2 + overlap])
  cylinder(h = button_height, r = button_diameter / 2, center = true);
}

module insulator_outer() {
  cylinder(h = insulator_height, r = button_diameter / 2 + insulator_thickness, center = true);
}

module insulator_inner_cut() {
  cylinder(h = insulator_height + 2 * overlap, r = button_diameter / 2, center = true);
}

module insulator_ring() {
  color("Black")
  translate([0, 0, cell_height / 2 - cap_height - insulator_height / 2 + overlap])
  difference() {
    insulator_outer();
    insulator_inner_cut();
  }
}

module label_wrap() {
  color("Blue")
  cylinder(h = label_height, r = cell_diameter / 2 + label_thickness, center = true);
}

module edge_fillet_top() {
  color("Silver")
  translate([0, 0, cell_height / 2 - fillet_radius])
  rotate_extrude() translate([cell_diameter / 2 - fillet_radius, 0, 0]) circle(r = fillet_radius);
}

module edge_fillet_bottom() {
  color("Silver")
  translate([0, 0, -cell_height / 2 + fillet_radius])
  rotate_extrude() translate([cell_diameter / 2 - fillet_radius, 0, 0]) circle(r = fillet_radius);
}

// Final Assembly
module main_cell_union() {
  union() {
    cell_body();
    top_cap();
    bottom_cap();
    positive_terminal_button();
    insulator_ring();
    label_wrap();
    edge_fillet_top();
    edge_fillet_bottom();
  }
}

// Render the final output
main_cell_union();