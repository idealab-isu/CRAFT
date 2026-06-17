// Parameters
radius = 2.0; //[1.0:4.0:0.1]
angle_deg = 0; //[-180:180:1]
height = 6; //[3:12:0.5]
post_diameter = 1.0; //[0.5:2.0:0.1]

// Convert angle from degrees to radians for trigonometric functions
angle_rad = angle_deg * 180 / pi;

// Base shape: Radial post
module radial_post_base() {
  color("DimGray")
  cylinder(h=height, r=post_diameter/2, center=true);
}

// Position the radial post based on polar coordinates
module radial_post_positioned() {
  translate([radius*cos(angle_rad), radius*sin(angle_rad), 0])
    radial_post_base();
}

// Final model
module model_union() {
  union() {
    radial_post_positioned();
  }
}

// Render the final model
model_union();