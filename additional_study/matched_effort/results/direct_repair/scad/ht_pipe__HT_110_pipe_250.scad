$fn = 180;

// HT pipe parameters (approximate for HT 110)
od = 110;          // outer diameter (mm)
wall = 3.2;        // wall thickness (mm) typical for HT 110
len = 250;         // length (mm)

id = od - 2*wall;

difference() {
    cylinder(h = len, d = od, center = false);
    translate([0,0,-0.1])
        cylinder(h = len + 0.2, d = id, center = false);
}