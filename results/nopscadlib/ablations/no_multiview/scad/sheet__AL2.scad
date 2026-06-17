// Parameters
plate_length = 300; //[150:600:1]
plate_width = 200; //[100:400:1]
plate_thickness = 10; //[5:20:1]
chamfer_size = 2; //[1:6:1]
edge_fillet_radius = 1; //[0.5:4:0.5]
label_depth = 0.3; //[0.1:1:0.1]

// Main tooling plate body
module tooling_plate_body() {
  color("Silver")
  cube([plate_length, plate_width, plate_thickness], center=true);
}

// Final output
tooling_plate_body();