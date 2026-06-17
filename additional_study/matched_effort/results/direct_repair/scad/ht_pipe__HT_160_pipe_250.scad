$fn = 128;

// HT pipe parameters (approximation)
od = 160;          // outer diameter in mm
length = 250;      // length in mm
wall = 4.9;        // typical wall thickness for DN160 HT pipe (approx.)
id = od - 2*wall;  // inner diameter

difference() {
    cylinder(h = length, d = od);
    translate([0,0,-0.5])
        cylinder(h = length + 1, d = id);
}