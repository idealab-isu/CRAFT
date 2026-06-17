$fn = 128;

// HT pipe (approx.) - DN40, length 250 mm
// Typical HT DN40 dimensions (approx):
// Outer diameter: 40 mm
// Wall thickness: 1.8 mm  -> Inner diameter: 36.4 mm
// Length: 250 mm

od = 40;
wall = 1.8;
id = od - 2*wall;
len = 250;

difference() {
  cylinder(h = len, d = od);
  translate([0,0,-0.1]) cylinder(h = len + 0.2, d = id);
}