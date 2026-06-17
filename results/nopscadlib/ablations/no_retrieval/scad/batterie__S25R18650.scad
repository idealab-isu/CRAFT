// Parameters
cell_H = 65.0; //[32.5:130.0:0.1]
cell_D = 18.3; //[9.15:36.6:0.1]
cap_H = 1.2; //[0.6:2.4:0.05]
cap_D = 5.5; //[2.75:11.0:0.1]
insulator_H = 0.6; //[0.3:1.2:0.05]
insulator_radial_thk = 1.0; //[0.5:2.0:0.05]
neg_face_H = 0.4; //[0.2:1.0:0.05]
wrap_H = 50.0; //[25.0:100.0:0.5]
wrap_radial_thk = 0.25; //[0.1:0.6:0.05]
wrap_z_offset = 0.0; //[-10.0:10.0:0.5]
edge_chamfer_H = 0.6; //[0.2:1.5:0.05]
edge_chamfer_radial = 0.6; //[0.2:1.5:0.05]
overlap = 0.8; //[0.2:2.0:0.1]

// Base Shapes
module cell_cylindrical_body() {
  color("Silver")
  cylinder(h=cell_H, r=cell_D/2, center=true);
}

module top_positive_cap() {
  color("DimGray")
  translate([0, 0, cell_H/2 + cap_H/2 - overlap])
  cylinder(h=cap_H, r=cap_D/2, center=true);
}

module bottom_negative_face() {
  color("DimGray")
  translate([0, 0, -cell_H/2 - neg_face_H/2 + overlap])
  cylinder(h=neg_face_H, r=cell_D/2, center=true);
}

module top_insulator_outer() {
  cylinder(h=insulator_H, r=cell_D/2, center=true);
}

module top_insulator_inner_cut() {
  cylinder(h=insulator_H + 2*overlap, r=cell_D/2 - insulator_radial_thk, center=true);
}

module top_insulator_ring() {
  color("Black")
  translate([0, 0, cell_H/2 + insulator_H/2 - overlap])
  difference() {
    top_insulator_outer();
    top_insulator_inner_cut();
  }
}

module edge_chamfer_top() {
  color("Silver")
  translate([0, 0, cell_H/2 - edge_chamfer_H/2 + overlap])
  cylinder(h=edge_chamfer_H, r1=cell_D/2, r2=cell_D/2 - edge_chamfer_radial, center=true);
}

module edge_chamfer_bottom() {
  color("Silver")
  translate([0, 0, -cell_H/2 + edge_chamfer_H/2 - overlap])
  cylinder(h=edge_chamfer_H, r1=cell_D/2 - edge_chamfer_radial, r2=cell_D/2, center=true);
}

module surface_label_wrap() {
  color("Blue")
  translate([0, 0, wrap_z_offset])
  cylinder(h=wrap_H, r=cell_D/2 + wrap_radial_thk, center=true);
}

// Final Assembly
module battery_cell_complete() {
  union() {
    cell_cylindrical_body();
    top_positive_cap();
    bottom_negative_face();
    top_insulator_ring();
    edge_chamfer_top();
    edge_chamfer_bottom();
    surface_label_wrap();
  }
}

// Render the complete battery cell
battery_cell_complete();