$fn = 180;

// HT pipe: nominal DN125, length 150 mm
// Assumptions (typical HT dimensions):
// - Outer diameter: 125 mm
// - Wall thickness: 3.2 mm (approx.)
// Adjust parameters if you need exact manufacturer dimensions.

od = 125;
wall = 3.2;
id = od - 2*wall;
len = 150;

difference() {
  cylinder(h = len, d = od);
  translate([0,0,-0.1]) cylinder(h = len + 0.2, d = id);
}