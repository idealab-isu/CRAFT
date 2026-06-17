// Parameters
cell_H = 61.5; //[30.75:123:0.1]
cell_D = 34.2; //[17.1:68.4:0.1]
terminal_D = 10; //[5:20:0.1]
terminal_H = 1.5; //[0.75:3:0.1]
bottom_contact_recess_D = 12; //[6:24:0.1]
bottom_contact_recess_depth = 0.3; //[0.15:0.6:0.05]
insulator_ring_OD = 16; //[8:32:0.1]
insulator_ring_ID = 11; //[5.5:22:0.1]
insulator_ring_H = 0.6; //[0.3:1.2:0.05]
label_thickness = 0.2; //[0.1:0.6:0.05]
label_H = 50; //[25:100:0.5]
label_top_margin = 5; //[2.5:10:0.5]
edge_chamfer = 0.6; //[0.3:1.2:0.05]
connect_overlap = 0.8; //[0.5:2:0.1]

// Base Shapes
module cell_body() {
  color("Silver")
  cylinder(h=cell_H, r=cell_D/2, center=true);
}

module top_positive_terminal() {
  color("DimGray")
  translate([0, 0, cell_H/2 + terminal_H/2 - connect_overlap])
  cylinder(h=terminal_H, r=terminal_D/2, center=true);
}

module bottom_negative_contact() {
  translate([0, 0, -cell_H/2 + bottom_contact_recess_depth/2])
  cylinder(h=bottom_contact_recess_depth, r=bottom_contact_recess_D/2, center=true);
}

module top_insulator_ring() {
  difference() {
    color("White")
    translate([0, 0, cell_H/2 + insulator_ring_H/2 - connect_overlap])
    cylinder(h=insulator_ring_H, r=insulator_ring_OD/2, center=true);
    translate([0, 0, cell_H/2 + insulator_ring_H/2 - connect_overlap])
    cylinder(h=insulator_ring_H + 2*connect_overlap, r=insulator_ring_ID/2, center=true);
  }
}

module label_wrap() {
  difference() {
    color("Blue")
    translate([0, 0, cell_H/2 - label_top_margin - label_H/2])
    cylinder(h=label_H, r=cell_D/2 + label_thickness, center=true);
    translate([0, 0, cell_H/2 - label_top_margin - label_H/2])
    cylinder(h=label_H + 2*connect_overlap, r=cell_D/2 - connect_overlap, center=true);
  }
}

module edge_chamfer_top_cone() {
  translate([0, 0, cell_H/2 - edge_chamfer/2])
  rotate([180, 0, 0])
  cylinder(h=edge_chamfer, r1=cell_D/2 + edge_chamfer, r2=0, center=true);
}

module edge_chamfer_bottom_cone() {
  translate([0, 0, -cell_H/2 + edge_chamfer/2])
  cylinder(h=edge_chamfer, r1=cell_D/2 + edge_chamfer, r2=0, center=true);
}

// Operations
module battery_complete() {
  difference() {
    union() {
      cell_body();
      top_positive_terminal();
      top_insulator_ring();
      label_wrap();
    }
    edge_chamfer_top_cone();
    edge_chamfer_bottom_cone();
    bottom_negative_contact();
  }
}

// Final Output
battery_complete();