// Parameters
outer_radius = 13.5; //[6.75:27:0.1]
inner_radius = 10.5; //[5.25:21:0.1]
height = 3.7; //[1.85:7.4:0.1]
overlap = 1; //[0.5:2:0.1]

// Annular Ring Geometry
module annular_ring() {
  difference() {
    // Outer cylinder
    cylinder(r=outer_radius, h=height, center=true);
    
    // Inner cylinder (subtracting)
    cylinder(r=inner_radius, h=height + 2*overlap, center=true);
  }
}

// Render the annular ring
color("Silver") annular_ring();