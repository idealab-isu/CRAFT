$fn = 128;

// HT 40 pipe (approx.): DN40, OD 40 mm, length 150 mm
// Typical wall thickness for HT40 is ~1.8 mm (varies by manufacturer).
// Adjust wall_thickness if needed.
od = 40;
wall_thickness = 1.8;
id = od - 2*wall_thickness;
length = 150;

difference() {
  cylinder(h = length, d = od);
  translate([0,0,-0.1]) cylinder(h = length + 0.2, d = id);
}