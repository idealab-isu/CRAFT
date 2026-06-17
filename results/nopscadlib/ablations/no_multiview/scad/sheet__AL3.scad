// Parameters
plate_L = 300; //[150:600:1]
plate_W = 200; //[100:400:1]
plate_T = 10; //[5:20:1]
chamfer = 1; //[0.5:3:0.1]
corner_R = 5; //[2.5:15:0.5]
hole_d = 10; //[5:20:0.5]
hole_edge_offset = 20; //[10:60:1]
hole_overlap = 1; //[0.5:2:0.1]
chamfer_overlap = 0.5; //[0.2:2:0.1]

// Base Shapes
module plate_body() {
  cube([plate_L, plate_W, plate_T], center=true);
}

module edge_chamfer_wedge_x() {
  rotate([0, 45, 0])
    cube([chamfer, plate_W + 2*chamfer_overlap, plate_T + 2*chamfer_overlap], center=true);
}

module edge_chamfer_wedge_y() {
  rotate([45, 0, 0])
    cube([plate_L + 2*chamfer_overlap, chamfer, plate_T + 2*chamfer_overlap], center=true);
}

module corner_radius_cutter() {
  cylinder(r=corner_R, h=plate_T + 2*hole_overlap, center=true);
}

module mounting_hole_cutter() {
  cylinder(r=hole_d/2, h=plate_T + 2*hole_overlap, center=true);
}

// Operations
module edge_chamfer_pos_x() {
  translate([plate_L/2 - chamfer/2, 0, 0])
    edge_chamfer_wedge_x();
}

module edge_chamfer_neg_x() {
  translate([-(plate_L/2 - chamfer/2), 0, 0])
    edge_chamfer_wedge_x();
}

module edge_chamfer_pos_y() {
  translate([0, plate_W/2 - chamfer/2, 0])
    edge_chamfer_wedge_y();
}

module edge_chamfer_neg_y() {
  translate([0, -(plate_W/2 - chamfer/2), 0])
    edge_chamfer_wedge_y();
}

module corner_radius_pp() {
  translate([plate_L/2 - corner_R, plate_W/2 - corner_R, 0])
    corner_radius_cutter();
}

module corner_radius_pn() {
  translate([plate_L/2 - corner_R, -(plate_W/2 - corner_R), 0])
    corner_radius_cutter();
}

module corner_radius_np() {
  translate([-(plate_L/2 - corner_R), plate_W/2 - corner_R, 0])
    corner_radius_cutter();
}

module corner_radius_nn() {
  translate([-(plate_L/2 - corner_R), -(plate_W/2 - corner_R), 0])
    corner_radius_cutter();
}

module mounting_hole_pp() {
  translate([plate_L/2 - hole_edge_offset, plate_W/2 - hole_edge_offset, 0])
    mounting_hole_cutter();
}

module mounting_hole_pn() {
  translate([plate_L/2 - hole_edge_offset, -(plate_W/2 - hole_edge_offset), 0])
    mounting_hole_cutter();
}

module mounting_hole_np() {
  translate([-(plate_L/2 - hole_edge_offset), plate_W/2 - hole_edge_offset, 0])
    mounting_hole_cutter();
}

module mounting_hole_nn() {
  translate([-(plate_L/2 - hole_edge_offset), -(plate_W/2 - hole_edge_offset), 0])
    mounting_hole_cutter();
}

// Final Output
difference() {
  color("Silver") plate_body();
  edge_chamfer_pos_x();
  edge_chamfer_neg_x();
  edge_chamfer_pos_y();
  edge_chamfer_neg_y();
  corner_radius_pp();
  corner_radius_pn();
  corner_radius_np();
  corner_radius_nn();
  mounting_hole_pp();
  mounting_hole_pn();
  mounting_hole_np();
  mounting_hole_nn();
  // Engraved label and surface texture are ignored as per no-text/no-decoration rule
}