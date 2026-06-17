// Parameters
body_length = 50; //[25:100:1]
body_width  = 30; //[15:60:1]
body_height = 10; //[5:20:1]

// Robust, non-zero dimensions (prevents blank renders)
eps = 0.01;
L = max(body_length, eps);
W = max(body_width,  eps);
H = max(body_height, eps);

// Main Body Module
module main_body() {
  cube([L, W, H], center=true);
}

// Final Model (one connected solid)
color([0.85, 0.85, 0.8])
union() {
  main_body();
}