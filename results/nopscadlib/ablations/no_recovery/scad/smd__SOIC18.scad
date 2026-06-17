// Parameters
body_length = 11.4; //[5.7:22.8:0.1]
body_width = 7.5; //[3.75:15:0.1]
body_height = 2; //[1:4:0.05]
mark_diameter = 1.2; //[0.6:2.4:0.05]
mark_depth = 0.25; //[0.1:0.6:0.05]
mark_edge_offset = 1.2; //[0.6:2.4:0.05]
chamfer_size = 0.6; //[0.2:1.2:0.05]
pin_length = 1.2; //[0.6:2.4:0.05]
pin_thickness = 0.25; //[0.1:0.6:0.05]
pin_width = 6.2; //[3:7.4:0.1]
overlap = 0.8; //[0.3:1.5:0.05]

// SMD Body
module smd_body() {
  color([0.85, 0.85, 0.8]) // Off-white for SMD package
  cube([body_length, body_width, body_height], center=true);
}

// Polarity Mark
module polarity_mark() {
  translate([-body_length/2 + mark_edge_offset, body_width/2 - mark_edge_offset, body_height/2 - mark_depth/2])
    color("Black")
    cylinder(h=mark_depth, r=mark_diameter/2, center=true);
}

// Edge Chamfer
module edge_chamfer() {
  color([0.85, 0.85, 0.8])
  union() {
    translate([-body_length/2 + chamfer_size/2, body_width/2 - chamfer_size/2, 0])
      rotate([0, 0, 45])
      cube([chamfer_size, chamfer_size, body_height], center=true);
    translate([body_length/2 - chamfer_size/2, body_width/2 - chamfer_size/2, 0])
      rotate([0, 0, 45])
      cube([chamfer_size, chamfer_size, body_height], center=true);
    translate([-body_length/2 + chamfer_size/2, -body_width/2 + chamfer_size/2, 0])
      rotate([0, 0, 45])
      cube([chamfer_size, chamfer_size, body_height], center=true);
    translate([body_length/2 - chamfer_size/2, -body_width/2 + chamfer_size/2, 0])
      rotate([0, 0, 45])
      cube([chamfer_size, chamfer_size, body_height], center=true);
  }
}

// Pin Terminations
module pin_terminations() {
  color("Silver") // Silver for pin terminations
  union() {
    translate([-body_length/2 - pin_length/2 + overlap/2, 0, -body_height/2 + pin_thickness/2])
      cube([pin_length + overlap, pin_width, pin_thickness], center=true);
    translate([body_length/2 + pin_length/2 - overlap/2, 0, -body_height/2 + pin_thickness/2])
      cube([pin_length + overlap, pin_width, pin_thickness], center=true);
  }
}

// Complete SMD Package
module smd_complete() {
  difference() {
    union() {
      smd_body();
      pin_terminations();
    }
    edge_chamfer();
    polarity_mark();
  }
}

// Render the final SMD package
smd_complete();