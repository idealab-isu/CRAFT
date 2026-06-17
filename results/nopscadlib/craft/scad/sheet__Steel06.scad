// Parameters
sheet_length = 1000; //[500:2000:1]
sheet_width = 500; //[250:1000:1]
sheet_thickness = 3; //[1.5:6:0.5]
corner_fillet_radius = 25; //[10:60:1]
mount_hole_diameter = 12; //[6:24:1]
mount_hole_edge_offset = 40; //[20:100:1]
edge_chamfer = 1; //[0.5:3:0.5]
overlap = 1; //[0.5:2:0.5]

// Base Shapes
module sheet_body_core() {
  cube([sheet_length - 2*corner_fillet_radius, sheet_width - 2*corner_fillet_radius, sheet_thickness], center=true);
}

module corner_cylinder(x, y) {
  translate([x, y, 0])
    cylinder(r=corner_fillet_radius, h=sheet_thickness, center=true);
}

module mount_hole(x, y) {
  translate([x, y, 0])
    cylinder(r=mount_hole_diameter/2, h=sheet_thickness + 2*overlap, center=true);
}

module chamfer_wedge(x, y, z, rx, ry, rz) {
  translate([x, y, z])
    rotate([rx, ry, rz])
      cube([edge_chamfer, sheet_width + 2*overlap, edge_chamfer], center=true);
}

// Operations
module corner_fillets() {
  union() {
    corner_cylinder(sheet_length/2 - corner_fillet_radius, sheet_width/2 - corner_fillet_radius);
    corner_cylinder(-sheet_length/2 + corner_fillet_radius, sheet_width/2 - corner_fillet_radius);
    corner_cylinder(-sheet_length/2 + corner_fillet_radius, -sheet_width/2 + corner_fillet_radius);
    corner_cylinder(sheet_length/2 - corner_fillet_radius, -sheet_width/2 + corner_fillet_radius);
  }
}

module sheet_body() {
  union() {
    sheet_body_core();
    corner_fillets();
  }
}

module mounting_holes() {
  union() {
    mount_hole(sheet_length/2 - mount_hole_edge_offset, sheet_width/2 - mount_hole_edge_offset);
    mount_hole(-sheet_length/2 + mount_hole_edge_offset, sheet_width/2 - mount_hole_edge_offset);
    mount_hole(-sheet_length/2 + mount_hole_edge_offset, -sheet_width/2 + mount_hole_edge_offset);
    mount_hole(sheet_length/2 - mount_hole_edge_offset, -sheet_width/2 + mount_hole_edge_offset);
  }
}

module edge_chamfer() {
  union() {
    chamfer_wedge(sheet_length/2 - edge_chamfer/2, 0, sheet_thickness/2 - edge_chamfer/2, 0, 45, 0);
    chamfer_wedge(-sheet_length/2 + edge_chamfer/2, 0, sheet_thickness/2 - edge_chamfer/2, 0, -45, 0);
    chamfer_wedge(0, sheet_width/2 - edge_chamfer/2, sheet_thickness/2 - edge_chamfer/2, 45, 0, 0);
    chamfer_wedge(0, -sheet_width/2 + edge_chamfer/2, sheet_thickness/2 - edge_chamfer/2, -45, 0, 0);
    chamfer_wedge(sheet_length/2 - edge_chamfer/2, 0, -sheet_thickness/2 + edge_chamfer/2, 0, -45, 0);
    chamfer_wedge(-sheet_length/2 + edge_chamfer/2, 0, -sheet_thickness/2 + edge_chamfer/2, 0, 45, 0);
    chamfer_wedge(0, sheet_width/2 - edge_chamfer/2, -sheet_thickness/2 + edge_chamfer/2, -45, 0, 0);
    chamfer_wedge(0, -sheet_width/2 + edge_chamfer/2, -sheet_thickness/2 + edge_chamfer/2, 45, 0, 0);
  }
}

// Final Output
difference() {
  sheet_body();
  mounting_holes();
  edge_chamfer();
}