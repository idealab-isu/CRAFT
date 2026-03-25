// Parameters
body_length = 50; //[25:100:1]
body_width  = 30; //[15:60:1]
body_height = 20; //[10:40:1]

// Ensure robust, non-degenerate geometry
eps = 0.01;

// Main Body Module
module main_body() {
  cube([body_length, body_width, body_height], center=true);
}

// Final Model (one connected solid)
main_body();