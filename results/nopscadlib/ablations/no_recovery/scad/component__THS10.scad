// Parameters
body_length = 50; //[25:100:1]
body_width = 50; //[25:100:1]
body_height = 20; //[10:40:1]

// Main body module
module main_body() {
  color([0.85, 0.85, 0.8]) // Off-white color for 3D printed PLA
  translate([0, 0, 0]) // Centered at origin
  cube([body_length, body_width, body_height], center=true);
}

// Final model
union() {
  main_body();
}