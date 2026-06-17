$fn = 128;

// HT pipe parameters (approximate, in mm)
outer_d = 125;      // nominal outer diameter
length  = 500;      // pipe length
wall    = 3.2;      // typical HT wall thickness (approx.)

inner_d = outer_d - 2*wall;

difference() {
    cylinder(h = length, d = outer_d, center = false);
    translate([0,0,-0.1])
        cylinder(h = length + 0.2, d = inner_d, center = false);
}