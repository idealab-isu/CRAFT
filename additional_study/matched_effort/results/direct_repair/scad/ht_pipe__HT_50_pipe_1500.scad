$fn = 128;

// HT 50 pipe (approx.): DN50, OD 50 mm, typical wall ~1.8 mm
// Length: 1500 mm

od = 50;          // outer diameter (mm)
wall = 1.8;       // wall thickness (mm)
id = od - 2*wall; // inner diameter (mm)
len = 1500;       // length (mm)

difference() {
  cylinder(h = len, d = od, center = false);
  translate([0,0,-0.5])
    cylinder(h = len + 1, d = id, center = false);
}