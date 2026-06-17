// Parameters
body_length = 6.5; //[3.25:13:0.1]
body_width = 3.5; //[1.75:7:0.1]
body_height = 1.6; //[0.8:3.2:0.05]
notch_length = 1.0; //[0.5:2.0:0.05]
notch_width = 0.8; //[0.4:1.6:0.05]
notch_depth = 0.3; //[0.1:0.8:0.05]
chamfer_size = 0.25; //[0.1:0.6:0.05]
overlap = 0.8; //[0.2:2.0:0.1]

// Base shapes
module smd_body() {
  cube([body_length, body_width, body_height], center=true);
}

module marking_notch() {
  translate([body_length/2 - notch_length/2, body_width/2 - notch_width/2, body_height/2 - notch_depth/2])
    cube([notch_length, notch_width, notch_depth + overlap], center=true);
}

module edge_chamfers() {
  sphere(r=chamfer_size);
}

// Operations
module body_with_chamfers() {
  minkowski() {
    smd_body();
    edge_chamfers();
  }
}

module final_smd_model() {
  difference() {
    body_with_chamfers();
    marking_notch();
  }
}

// Final output
color([0.85, 0.85, 0.8]) // Off-white color for SMD package
final_smd_model();