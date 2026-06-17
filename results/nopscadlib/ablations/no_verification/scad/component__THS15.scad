// Parameters
body_length = 50; //[25:100:1]
body_width  = 30; //[15:60:1]
body_height = 10; //[5:20:1]

$fn = 64;

// Main Body Module
module main_body() {
  cube([body_length, body_width, body_height], center=true);
}

// Final Model (single connected solid)
color([0.85, 0.85, 0.8])
union() {
  main_body();
}