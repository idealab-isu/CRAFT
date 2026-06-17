// Parameters
body_length = 50; //[25:100:1]
body_width = 30; //[15:60:1]
body_height = 10; //[5:20:1]

// Main Body Module
module main_body() {
  color([0.85, 0.85, 0.8]) // Off-white for 3D printed PLA
  translate([0, 0, 0])
    cube([body_length, body_width, body_height], center=true);
}

// Final Model
union() {
  main_body();
}