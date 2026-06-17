// Parameters
body_length = 50; //[25:100:1]
body_width  = 50; //[25:100:1]
body_height = 20; //[10:40:1]

eps = 0.01;

// Main Body Module
module main_body() {
  color([0.85, 0.85, 0.8])
    cube([body_length, body_width, body_height], center=true);
}

// Final Model (single connected solid, centered at origin for reliable viewing)
union() {
  main_body();
}