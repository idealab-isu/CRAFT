$fn = 128;

// HT pipe parameters (approximate for HT 125)
od = 125;          // outer diameter (mm)
wall = 3.2;        // wall thickness (mm) typical for HT 125
len = 1000;        // length (mm)

id = od - 2*wall;

difference() {
    cylinder(h = len, d = od, center = false);
    translate([0,0,-0.5])
        cylinder(h = len + 1, d = id, center = false);
}