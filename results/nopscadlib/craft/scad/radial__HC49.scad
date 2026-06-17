// Parameters
outer_radius = 13.5; //[6.75:27:0.1]
inner_radius = 10.5; //[5.25:21:0.1]
height = 3.7; //[1.85:7.4:0.1]

// Geometry
module radial_ring() {
  difference() {
    // Outer cylinder
    cylinder(r=outer_radius, h=height, center=true);
    
    // Inner cylinder (cut)
    cylinder(r=inner_radius, h=height + 2, center=true);
  }
}

// Final output
color("Silver") radial_ring();