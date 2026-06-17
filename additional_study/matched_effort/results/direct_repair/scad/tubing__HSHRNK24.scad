$fn = 128;

// Heatshrink sleeving (tubing)
inner_d = 6;          // mm
wall_thickness = 0.8; // mm
length = 40;          // mm

outer_d = inner_d + 2 * wall_thickness;

difference() {
  cylinder(h = length, d = outer_d, center = false);
  translate([0, 0, -0.5])
    cylinder(h = length + 1, d = inner_d, center = false);
}