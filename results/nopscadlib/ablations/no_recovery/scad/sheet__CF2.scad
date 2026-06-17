// Parameters
sheet_length = 300; //[150:600:1]
sheet_width = 200; //[100:400:1]
sheet_thickness = 2; //[1:6:0.1]
corner_radius = 5; //[2.5:10:0.5]
chamfer_size = 0.5; //[0.25:1.5:0.05]
edge_overlap = 1; //[0.5:2:0.1]
texture_depth = 0; //[0:0:0]
label_depth = 0; //[0:0:0]

// Base Shapes
module sheet_plate() {
  cube([sheet_length, sheet_width, sheet_thickness], center=true);
}

module rounded_corners() {
  cube([sheet_length - 2*corner_radius, sheet_width - 2*corner_radius, sheet_thickness], center=true);
}

module corner_cyl_1() {
  translate([sheet_length/2 - corner_radius, sheet_width/2 - corner_radius, 0])
    cylinder(r=corner_radius, h=sheet_thickness, center=true);
}

module corner_cyl_2() {
  translate([-sheet_length/2 + corner_radius, sheet_width/2 - corner_radius, 0])
    cylinder(r=corner_radius, h=sheet_thickness, center=true);
}

module corner_cyl_3() {
  translate([-sheet_length/2 + corner_radius, -sheet_width/2 + corner_radius, 0])
    cylinder(r=corner_radius, h=sheet_thickness, center=true);
}

module corner_cyl_4() {
  translate([sheet_length/2 - corner_radius, -sheet_width/2 + corner_radius, 0])
    cylinder(r=corner_radius, h=sheet_thickness, center=true);
}

module edge_chamfer() {
  cube([sheet_length - 2*chamfer_size, sheet_width - 2*chamfer_size, sheet_thickness - 2*chamfer_size], center=true);
}

module surface_weave_texture() {
  translate([0, 0, sheet_thickness/2 - texture_depth/2])
    cube([sheet_length, sheet_width, texture_depth], center=true);
}

module engraved_label() {
  translate([0, 0, sheet_thickness/2 - label_depth/2])
    cube([sheet_length/3, sheet_width/6, label_depth], center=true);
}

// Operations
module rounded_plate_union() {
  union() {
    rounded_corners();
    corner_cyl_1();
    corner_cyl_2();
    corner_cyl_3();
    corner_cyl_4();
  }
}

module rounded_plate() {
  intersection() {
    sheet_plate();
    rounded_plate_union();
  }
}

module chamfered_plate() {
  difference() {
    rounded_plate();
    edge_chamfer();
  }
}

module final_model() {
  union() {
    chamfered_plate();
    surface_weave_texture();
    engraved_label();
  }
}

// Final Output
final_model();