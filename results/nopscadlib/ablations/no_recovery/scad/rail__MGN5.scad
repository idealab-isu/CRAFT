// Parameters
rail_length = 100.0; //[50.0:200.0:1]
rail_width = 5.0; //[2.5:10.0:0.1]
rail_height = 3.6; //[1.8:7.2:0.1]

// Rail Body
module rail_body() {
  color("Silver") // Aluminum-like appearance
  translate([0, 0, 0]) // Centered at origin
    cube([rail_width, rail_length, rail_height], center=true);
}

// Final Model
module rail_model() {
  rail_body();
}

// Render the final output
rail_model();