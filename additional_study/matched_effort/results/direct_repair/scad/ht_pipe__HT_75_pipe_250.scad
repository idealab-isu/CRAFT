$fn = 128;

// HT pipe: DN75, length 250 mm (approximate dimensions)
// Typical HT DN75: OD ~ 75 mm, wall ~ 2.7 mm
// Adjust as needed for your specific standard/manufacturer.

od = 75;          // outer diameter (mm)
wall = 2.7;       // wall thickness (mm)
len = 250;        // length (mm)

id = od - 2*wall; // inner diameter (mm)

difference() {
  cylinder(h = len, d = od);
  translate([0,0,-0.5])
    cylinder(h = len + 1, d = id);
}