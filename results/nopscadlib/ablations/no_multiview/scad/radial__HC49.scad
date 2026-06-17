// Parameters
outer_radius = 10.5; //[5.25:21:0.1]
inner_radius = 3.7; //[1.85:7.4:0.1]
height = 13.5; //[6.75:27:0.1]

// Geometry
module outer_cylinder() {
  cylinder(h=height, r=outer_radius, center=true);
}

module inner_bore() {
  cylinder(h=height + 2, r=inner_radius, center=true);
}

// Main Body
module main_body() {
  difference() {
    outer_cylinder();
    inner_bore();
  }
}

// Final Output
color("Silver") main_body();