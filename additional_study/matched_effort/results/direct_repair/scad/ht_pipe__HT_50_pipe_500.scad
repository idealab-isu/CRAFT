$fn = 128;

// HT 50 pipe (approx.): DN 50, length 500 mm
// Typical dimensions (approx. for HT 50):
// Outer diameter: 50 mm
// Wall thickness: 1.8 mm  -> inner diameter: 46.4 mm
// No socket modeled (straight pipe)

length = 500;
od = 50;
wall = 1.8;
id = od - 2*wall;

difference() {
    cylinder(h = length, d = od);
    translate([0,0,-0.5])
        cylinder(h = length + 1, d = id);
}