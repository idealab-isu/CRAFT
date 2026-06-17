// Parameters
body_length = 50; //[25:100:1]
body_width = 50; //[25:100:1]
body_height = 20; //[10:40:1]

// Main Body Module
module main_body() {
  color("Silver") // Use a neutral color for the main body
  translate([0, 0, 0]) // Centered at origin
    cube([body_length, body_width, body_height], center=true);
}

// Final Model
union() {
  main_body();
}