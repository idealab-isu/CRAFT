// Parameters
sheet_length = 300; //[150:600:1]
sheet_width = 200; //[100:400:1]
sheet_thickness = 2; //[1:6:0.5]
corner_radius = 5; //[2:20:1]
mount_hole_diameter = 6; //[3:12:0.5]
mount_hole_edge_offset = 15; //[8:40:1]
hole_clearance_z = 2; //[1:10:1]

// Base shapes
module sheet_plate() {
  cube([sheet_length, sheet_width, sheet_thickness], center=true);
}

module corner_cut_cylinder(x, y) {
  translate([x, y, 0])
    cylinder(r=corner_radius, h=sheet_thickness + hole_clearance_z, center=true);
}

module corner_cut_box(x, y) {
  translate([x, y, 0])
    cube([corner_radius, corner_radius, sheet_thickness + hole_clearance_z], center=true);
}

module mounting_hole(x, y) {
  translate([x, y, 0])
    cylinder(r=mount_hole_diameter/2, h=sheet_thickness + hole_clearance_z, center=true);
}

// Operations
module corner_cut_union() {
  union() {
    corner_cut_cylinder(sheet_length/2 - corner_radius, sheet_width/2 - corner_radius);
    corner_cut_box(sheet_length/2 - corner_radius/2, sheet_width/2 - corner_radius/2);
    corner_cut_cylinder(-sheet_length/2 + corner_radius, sheet_width/2 - corner_radius);
    corner_cut_box(-sheet_length/2 + corner_radius/2, sheet_width/2 - corner_radius/2);
    corner_cut_cylinder(-sheet_length/2 + corner_radius, -sheet_width/2 + corner_radius);
    corner_cut_box(-sheet_length/2 + corner_radius/2, -sheet_width/2 + corner_radius/2);
    corner_cut_cylinder(sheet_length/2 - corner_radius, -sheet_width/2 + corner_radius);
    corner_cut_box(sheet_length/2 - corner_radius/2, -sheet_width/2 + corner_radius/2);
  }
}

module rounded_sheet() {
  difference() {
    sheet_plate();
    corner_cut_union();
  }
}

module mount_holes_union() {
  union() {
    mounting_hole(sheet_length/2 - mount_hole_edge_offset, sheet_width/2 - mount_hole_edge_offset);
    mounting_hole(-sheet_length/2 + mount_hole_edge_offset, sheet_width/2 - mount_hole_edge_offset);
    mounting_hole(-sheet_length/2 + mount_hole_edge_offset, -sheet_width/2 + mount_hole_edge_offset);
    mounting_hole(sheet_length/2 - mount_hole_edge_offset, -sheet_width/2 + mount_hole_edge_offset);
  }
}

module final_sheet() {
  difference() {
    rounded_sheet();
    mount_holes_union();
  }
}

// Final output
color([0.0, 0.4, 0.2]) // Carbon-fiber sheet color
final_sheet();