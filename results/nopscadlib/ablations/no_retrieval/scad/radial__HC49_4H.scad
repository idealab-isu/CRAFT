// Parameters
outer_radius = 10.5; //[5.25:21:0.1]
inner_radius = 3.5; //[1.75:7:0.1]
height = 3.7; //[1.85:7.4:0.1]
bore_clearance = 0.5; //[0.2:2:0.1]

// Geometry
module radial_body() {
  cylinder(h=height, r=outer_radius, center=true);
}

module center_bore() {
  cylinder(h=height + 2*bore_clearance, r=inner_radius, center=true);
}

// Final Model
module ring_model() {
  difference() {
    radial_body();
    center_bore();
  }
}

// Render the final output
color("Silver") ring_model();