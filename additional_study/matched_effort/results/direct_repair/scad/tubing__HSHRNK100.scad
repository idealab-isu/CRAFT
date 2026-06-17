$fn = 128;

// Heatshrink sleeving (tubing)
inner_d = 6;          // mm
wall = 0.6;           // mm
length = 60;          // mm

outer_d = inner_d + 2*wall;

difference() {
  cylinder(h = length, d = outer_d, center = false);
  translate([0,0,-0.1])
    cylinder(h = length + 0.2, d = inner_d, center = false);
}