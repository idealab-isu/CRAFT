// Parameters
body_length = 50; //[25:100:1]
body_width  = 30; //[15:60:1]
body_height = 10; //[5:20:1]

$fn = 64;

// Main Body (single connected solid)
module main_body() {
  // Ensure non-zero, valid dimensions to avoid empty/blank renders
  L = max(body_length, 0.1);
  W = max(body_width,  0.1);
  H = max(body_height, 0.1);

  color([0.85, 0.85, 0.8])
    cube([L, W, H], center=true);
}

// Final Model
main_body();