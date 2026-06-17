$fn = 128;

// Heatshrink sleeving (tubing)
inner_d = 6;          // inner diameter (mm)
wall = 1;             // wall thickness (mm)
length = 60;          // length (mm)

outer_d = inner_d + 2*wall;

difference() {
  cylinder(h = length, d = outer_d, center = false);
  translate([0,0,-0.1])
    cylinder(h = length + 0.2, d = inner_d, center = false);
}