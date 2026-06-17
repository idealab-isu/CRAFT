// Parameters
cell_height = 80.2; //[40.1:160.4:0.1]
cell_diameter = 46.2; //[23.1:92.4:0.1]
cap_height = 1.0; //[0.5:2.0:0.1]
cap_inset = 0.2; //[0.1:0.6:0.05]
label_thickness = 0.15; //[0.05:0.4:0.05]
label_height = 70.0; //[35.0:78.2:0.1]
terminal_button_diameter = 16.0; //[8.0:24.0:0.1]
terminal_button_height = 1.6; //[0.8:3.2:0.1]
insulator_outer_diameter = 22.0; //[12.0:34.0:0.1]
insulator_inner_diameter = 17.0; //[9.0:28.0:0.1]
insulator_thickness = 0.6; //[0.3:1.2:0.05]
fillet_radius = 0.8; //[0.3:2.0:0.1]
overlap = 0.8; //[0.5:2.0:0.1]

// Base Shapes
module cell_body() {
  color("Silver")
  cylinder(h=cell_height, r=cell_diameter/2, center=true);
}

module top_cap() {
  color("DimGray")
  translate([0, 0, cell_height/2 - cap_height/2 + overlap/2])
  cylinder(h=cap_height, r=cell_diameter/2 - cap_inset, center=true);
}

module bottom_cap() {
  color("DimGray")
  translate([0, 0, -cell_height/2 + cap_height/2 - overlap/2])
  cylinder(h=cap_height, r=cell_diameter/2 - cap_inset, center=true);
}

module positive_terminal_button() {
  color("Gold")
  translate([0, 0, cell_height/2 + terminal_button_height/2 - overlap])
  cylinder(h=terminal_button_height, r=terminal_button_diameter/2, center=true);
}

module insulator_ring() {
  color("Black")
  difference() {
    translate([0, 0, cell_height/2 + insulator_thickness/2 - overlap])
    cylinder(h=insulator_thickness, r=insulator_outer_diameter/2, center=true);
    translate([0, 0, cell_height/2 + insulator_thickness/2 - overlap])
    cylinder(h=insulator_thickness + overlap*2, r=insulator_inner_diameter/2, center=true);
  }
}

module label_wrap() {
  color("Blue")
  cylinder(h=label_height, r=cell_diameter/2 + label_thickness, center=true);
}

module edge_fillet_top() {
  translate([0, 0, cell_height/2 - fillet_radius + overlap/2])
  rotate_extrude() translate([cell_diameter/2 - fillet_radius, 0, 0]) circle(r=fillet_radius);
}

module edge_fillet_bottom() {
  translate([0, 0, -cell_height/2 + fillet_radius - overlap/2])
  rotate_extrude() translate([cell_diameter/2 - fillet_radius, 0, 0]) circle(r=fillet_radius);
}

module edge_fillets() {
  union() {
    edge_fillet_top();
    edge_fillet_bottom();
  }
}

// Final Assembly
module battery_complete() {
  union() {
    cell_body();
    top_cap();
    bottom_cap();
    positive_terminal_button();
    insulator_ring();
    label_wrap();
    edge_fillets();
  }
}

// Render the complete battery
battery_complete();