// Parameters
body_length = 3.0; //[1.5:6.0:0.1]
body_width = 1.4; //[0.7:2.8:0.1]
body_height = 1.0; //[0.5:2.0:0.1]
terminal_length = 0.35; //[0.2:0.8:0.05]
terminal_thickness = 0.12; //[0.05:0.3:0.01]
terminal_wrap_height = 0.55; //[0.3:1.0:0.05]
mark_length = 1.0; //[0.5:2.0:0.1]
mark_width = 0.5; //[0.2:1.2:0.05]
mark_thickness = 0.05; //[0.02:0.15:0.01]
fillet_radius = 0.08; //[0.03:0.2:0.01]
overlap = 0.6; //[0.3:1.5:0.1]

// Main body with rounded edges
module main_body() {
  minkowski() {
    translate([0, 0, 0])
      cube([body_length - 2*fillet_radius, body_width - 2*fillet_radius, body_height - 2*fillet_radius], center=true);
    sphere(r=fillet_radius);
  }
}

// Terminal on the left
module terminal_left() {
  translate([-(body_length/2 - terminal_length/2 + overlap), 0, -(body_height/2 - terminal_wrap_height/2 + overlap)])
    cube([terminal_length, body_width, terminal_wrap_height], center=true);
}

// Terminal on the right
module terminal_right() {
  translate([(body_length/2 - terminal_length/2 + overlap), 0, -(body_height/2 - terminal_wrap_height/2 + overlap)])
    cube([terminal_length, body_width, terminal_wrap_height], center=true);
}

// Top marking pad
module top_marking() {
  translate([0, 0, (body_height/2 - mark_thickness/2 - overlap)])
    cube([mark_length, mark_width, mark_thickness], center=true);
}

// Complete SMD component
module smd_component() {
  color([0.85, 0.85, 0.8]) // Off-white for the main body
  union() {
    main_body();
    color([0.2, 0.2, 0.2]) // Dark color for terminals
    union() {
      terminal_left();
      terminal_right();
    }
    color([0.1, 0.1, 0.6]) // Blue for the top marking
    top_marking();
  }
}

// Render the SMD component
smd_component();