// Parameters
body_length = 50; //[25:100:1]
body_width  = 50; //[25:100:1]
body_height = 20; //[10:40:1]

$fn = 64;

// Main Body (single connected solid, centered)
module main_body() {
  color([0.85, 0.85, 0.8])
    cube([body_length, body_width, body_height], center=true);
}

// Final Model
main_body();