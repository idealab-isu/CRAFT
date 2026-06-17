// Parameters
plate_length = 300; //[150:600:1]
plate_width = 200; //[100:400:1]
plate_thickness = 12; //[6:24:1]
corner_radius = 10; //[5:20:1]
chamfer_leg = 6; //[3:12:1]
overlap = 1; //[0.5:2:0.5]

// Base Shapes
module tooling_plate_body() {
  cube([plate_length, plate_width, plate_thickness], center=true);
}

module rounded_corner_cutter_cyl() {
  cylinder(r=corner_radius, h=plate_thickness + 2*overlap, center=true);
}

module rounded_corner_cutter_box() {
  cube([corner_radius + overlap, corner_radius + overlap, plate_thickness + 2*overlap], center=true);
}

module chamfer_corner_cut_box() {
  cube([chamfer_leg, chamfer_leg, plate_thickness + 2*overlap], center=true);
}

module engraved_label() {
  cube([plate_length/3, plate_width/6, plate_thickness/10], center=true);
}

// Operations
module rounded_corner_cutter_quadrant() {
  intersection() {
    rounded_corner_cutter_cyl();
    translate([corner_radius/2, corner_radius/2, 0]) rounded_corner_cutter_box();
  }
}

module rounded_corners() {
  union() {
    translate([plate_length/2 - corner_radius, plate_width/2 - corner_radius, 0]) rounded_corner_cutter_quadrant();
    translate([-(plate_length/2 - corner_radius), plate_width/2 - corner_radius, 0]) rounded_corner_cutter_quadrant();
    translate([-(plate_length/2 - corner_radius), -(plate_width/2 - corner_radius), 0]) rounded_corner_cutter_quadrant();
    translate([plate_length/2 - corner_radius, -(plate_width/2 - corner_radius), 0]) rounded_corner_cutter_quadrant();
  }
}

module chamfer_corner_cut() {
  intersection() {
    rotate([0, 0, 45]) translate([plate_length/2 - chamfer_leg/2 + overlap, plate_width/2 - chamfer_leg/2 + overlap, 0]) chamfer_corner_cut_box();
    rotate([0, 0, 45]) translate([plate_length/2 - chamfer_leg/2 + overlap, plate_width/2 - chamfer_leg/2 + overlap, 0]) chamfer_corner_cut_box();
  }
}

module corner_chamfers() {
  union() {
    chamfer_corner_cut();
    translate([-(plate_length - 2*chamfer_leg)/2, 0, 0]) chamfer_corner_cut();
    translate([-(plate_length - 2*chamfer_leg)/2, -(plate_width - 2*chamfer_leg)/2, 0]) chamfer_corner_cut();
    translate([0, -(plate_width - 2*chamfer_leg)/2, 0]) chamfer_corner_cut();
  }
}

// Final Model
module complete_model() {
  difference() {
    difference() {
      difference() {
        tooling_plate_body();
        rounded_corners();
      }
      corner_chamfers();
    }
    translate([0, 0, plate_thickness/2 - (plate_thickness/10)/2]) engraved_label();
  }
}

// Render the complete model
color("Silver") complete_model();