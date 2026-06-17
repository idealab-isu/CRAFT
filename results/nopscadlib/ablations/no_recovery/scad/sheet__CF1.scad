// Parameters
sheet_L = 200; //[100:400:1]
sheet_W = 150; //[75:300:1]
sheet_T = 2; //[1:6:0.5]
edge_chamfer = 0.5; //[0.2:2:0.1]
corner_R = 5; //[2.5:10:0.5]
hole_d = 6; //[3:12:0.5]
hole_edge_offset = 15; //[8:30:1]
hole_overlap = 1; //[0.5:2:0.5]
texture_T = 0.2; //[0.1:0.6:0.1]
label_depth = 0.2; //[0.1:0.6:0.1]

// Base shapes
module sheet_plate_core_box() {
  cube([sheet_L - 2*corner_R, sheet_W - 2*corner_R, sheet_T], center=true);
}

module corner_cylinder(x, y) {
  translate([x, y, 0])
    cylinder(r=corner_R, h=sheet_T, center=true);
}

module edge_chamfer_sphere() {
  sphere(r=edge_chamfer);
}

module mount_hole_cylinder(x, y) {
  translate([x, y, 0])
    cylinder(r=hole_d/2, h=sheet_T + 2*hole_overlap, center=true);
}

// Operations
module sheet_plate_with_corner_radius() {
  union() {
    sheet_plate_core_box();
    corner_cylinder(sheet_L/2 - corner_R, sheet_W/2 - corner_R);
    corner_cylinder(-sheet_L/2 + corner_R, sheet_W/2 - corner_R);
    corner_cylinder(-sheet_L/2 + corner_R, -sheet_W/2 + corner_R);
    corner_cylinder(sheet_L/2 - corner_R, -sheet_W/2 + corner_R);
  }
}

module sheet_plate_with_mounting_holes() {
  difference() {
    sheet_plate_with_corner_radius();
    mount_hole_cylinder(sheet_L/2 - hole_edge_offset, sheet_W/2 - hole_edge_offset);
    mount_hole_cylinder(-sheet_L/2 + hole_edge_offset, sheet_W/2 - hole_edge_offset);
    mount_hole_cylinder(-sheet_L/2 + hole_edge_offset, -sheet_W/2 + hole_edge_offset);
    mount_hole_cylinder(sheet_L/2 - hole_edge_offset, -sheet_W/2 + hole_edge_offset);
  }
}

// Final output
color([0.2, 0.2, 0.2]) // Carbon-fiber appearance
sheet_plate_with_mounting_holes();