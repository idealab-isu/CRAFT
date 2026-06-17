// Parameters
body_length = 3.0; //[1.5:6.0:0.1]
body_width = 1.8; //[0.9:3.6:0.1]
body_height = 0.9; //[0.45:1.8:0.05]
pad_length = 0.6; //[0.3:1.2:0.05]
pad_width = 1.4; //[0.7:1.8:0.05]
pad_thickness = 0.08; //[0.03:0.2:0.01]
pad_overlap = 0.6; //[0.3:1.2:0.05]
polarity_mark_radius = 0.18; //[0.1:0.4:0.01]
polarity_mark_depth = 0.08; //[0.03:0.2:0.01]
polarity_mark_edge_margin = 0.35; //[0.2:0.8:0.05]
chamfer_size = 0.2; //[0.1:0.5:0.05]
connect_overlap = 0.8; //[0.5:2.0:0.1]

// Main body with chamfers
module main_body() {
  difference() {
    cube([body_length, body_width, body_height], center=true);
    translate([-body_length/2 + chamfer_size/2, body_width/2 - chamfer_size/2, 0])
      cube([chamfer_size, chamfer_size, body_height + 2*connect_overlap], center=true);
    translate([body_length/2 - chamfer_size/2, body_width/2 - chamfer_size/2, 0])
      cube([chamfer_size, chamfer_size, body_height + 2*connect_overlap], center=true);
    translate([-body_length/2 + chamfer_size/2, -body_width/2 + chamfer_size/2, 0])
      cube([chamfer_size, chamfer_size, body_height + 2*connect_overlap], center=true);
    translate([body_length/2 - chamfer_size/2, -body_width/2 + chamfer_size/2, 0])
      cube([chamfer_size, chamfer_size, body_height + 2*connect_overlap], center=true);
  }
}

// Polarity mark
module polarity_mark() {
  difference() {
    main_body();
    translate([-body_length/2 + polarity_mark_edge_margin, body_width/2 - polarity_mark_edge_margin, body_height/2 - polarity_mark_depth/2 + connect_overlap/2])
      cylinder(r=polarity_mark_radius, h=polarity_mark_depth + connect_overlap, center=true);
  }
}

// Terminal pads
module terminal_pads() {
  union() {
    translate([-body_length/2 + (pad_length + pad_overlap)/2 - connect_overlap, 0, -body_height/2 + pad_thickness/2 - connect_overlap])
      cube([pad_length + pad_overlap, pad_width, pad_thickness], center=true);
    translate([body_length/2 - (pad_length + pad_overlap)/2 + connect_overlap, 0, -body_height/2 + pad_thickness/2 - connect_overlap])
      cube([pad_length + pad_overlap, pad_width, pad_thickness], center=true);
  }
}

// Complete SMD package
module smd_complete() {
  union() {
    polarity_mark();
    terminal_pads();
  }
}

// Render the final SMD package
smd_complete();