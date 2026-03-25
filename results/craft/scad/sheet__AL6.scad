// Parameters
plate_length = 300; //[150:600:1]
plate_width = 200; //[100:400:1]
plate_thickness = 12; //[6:24:1]
corner_radius = 10; //[5:20:1]
edge_fillet_radius = 1; //[0.5:3:0.5]
corner_chamfer = 2; //[1:6:0.5]
connect_overlap = 1; //[0.5:2:0.5]

// Base shapes
module tooling_plate_body() {
  color("Silver")
  cube([plate_length, plate_width, plate_thickness], center=true);
}

module rounded_corners() {
  color("Silver")
  union() {
    translate([plate_length/2 - corner_radius, plate_width/2 - corner_radius, 0])
      cylinder(r=corner_radius, h=plate_thickness + 2*connect_overlap, center=true);
    translate([-plate_length/2 + corner_radius, plate_width/2 - corner_radius, 0])
      cylinder(r=corner_radius, h=plate_thickness + 2*connect_overlap, center=true);
    translate([-plate_length/2 + corner_radius, -plate_width/2 + corner_radius, 0])
      cylinder(r=corner_radius, h=plate_thickness + 2*connect_overlap, center=true);
    translate([plate_length/2 - corner_radius, -plate_width/2 + corner_radius, 0])
      cylinder(r=corner_radius, h=plate_thickness + 2*connect_overlap, center=true);
  }
}

module rounded_corners_rect_x() {
  color("Silver")
  cube([plate_length - 2*corner_radius, plate_width, plate_thickness], center=true);
}

module rounded_corners_rect_y() {
  color("Silver")
  cube([plate_length, plate_width - 2*corner_radius, plate_thickness], center=true);
}

module edge_fillet_sphere() {
  sphere(r=edge_fillet_radius, center=true);
}

// Operations
module rounded_corners_union() {
  union() {
    rounded_corners_rect_x();
    rounded_corners_rect_y();
    rounded_corners();
  }
}

module edge_fillet() {
  minkowski() {
    rounded_corners_union();
    edge_fillet_sphere();
  }
}

module tooling_plate_complete() {
  union() {
    edge_fillet();
    tooling_plate_body();
  }
}

// Final output
tooling_plate_complete();