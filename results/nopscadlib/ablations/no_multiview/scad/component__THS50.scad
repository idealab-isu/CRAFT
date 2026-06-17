// Parameters
body_length = 50; //[25:100:1]
body_width = 30; //[15:60:1]
body_height = 15; //[8:30:1]

// Main Body
module main_body() {
  color("Silver") // Use a neutral color for the main body
  cube([body_length, body_width, body_height], center=true);
}

// Final Component
module component_union() {
  union() {
    main_body();
  }
}

// Render the final component
component_union();