// Parameters
rail_length = 100.0; //[50.0:200.0:1]
rail_width = 15.0; //[7.5:30.0:0.5]
rail_height = 15.0; //[7.5:30.0:0.5]

// Rail Body Module
module rail_body() {
  color("Silver") // Aluminum-like appearance
  translate([0, 0, 0]) // Centered position
    cube([rail_length, rail_width, rail_height], center=true);
}

// Final Rail Model
rail_body();