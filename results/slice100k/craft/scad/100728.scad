// Simple solid right circular cylinder (rod)
// Bounding box: 3.0 x 3.0 x 26.0 mm

$fn = 128;  // ensure circular appearance in orthographic views

shaft_diameter = 3.0; //[1.5:6.0:0.1]
shaft_length   = 26.0; //[13.0:52.0:0.5]

cylinder(h = shaft_length, d = shaft_diameter, center = true);