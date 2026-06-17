$fn = 128;

// HT 50 pipe (approx): DN 50, length 250 mm
// Typical HT dimensions (approx):
// Outer diameter: 50 mm
// Wall thickness: 1.8 mm  -> inner diameter: 46.4 mm
// Length: 250 mm

od = 50;
wall = 1.8;
id = od - 2*wall;
L = 250;

difference() {
  cylinder(h = L, d = od);
  translate([0,0,-0.5])
    cylinder(h = L + 1, d = id);
}