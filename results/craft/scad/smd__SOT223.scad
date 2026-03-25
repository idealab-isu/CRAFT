// Parameters
body_length = 6.5; //[3.25:13:0.1]
body_width = 3.5; //[1.75:7:0.1]
body_height = 1.6; //[0.8:3.2:0.05]
notch_radius = 0.45; //[0.2:0.9:0.05]
notch_depth = 0.35; //[0.15:0.8:0.05]
chamfer = 0.25; //[0.1:0.6:0.05]
pad_length = 1.1; //[0.6:2.2:0.05]
pad_thickness = 0.12; //[0.05:0.3:0.01]
pad_inset_y = 0.2; //[0:0.8:0.05]
overlap = 0.8; //[0.5:2:0.1]

// Main body with chamfers
module main_body() {
  difference() {
    minkowski() {
      cube([body_length, body_width, body_height], center=true);
      sphere(r=chamfer);
    }
    translate([body_length/2 - notch_depth, body_width/2 - notch_depth, 0])
      cylinder(r=notch_radius, h=body_height + 2*chamfer + 2, center=true);
  }
}

// Terminal pads
module terminal_pads() {
  union() {
    translate([-(body_length/2) + (pad_length + overlap)/2 - overlap, 0, -(body_height/2) - (pad_thickness + overlap)/2 + overlap])
      cube([pad_length + overlap, body_width - 2*pad_inset_y, pad_thickness + overlap], center=true);
    translate([(body_length/2) - (pad_length + overlap)/2 + overlap, 0, -(body_height/2) - (pad_thickness + overlap)/2 + overlap])
      cube([pad_length + overlap, body_width - 2*pad_inset_y, pad_thickness + overlap], center=true);
  }
}

// Final SMD package
module smd_package() {
  color([0.85, 0.85, 0.8]) // Off-white for the main body
    main_body();
  color([0.2, 0.2, 0.2]) // Dark color for the pads
    terminal_pads();
}

// Render the SMD package
smd_package();