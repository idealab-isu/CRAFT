$fn = 128;

// HT pipe parameters (approximate for HT 110)
outer_d = 110;          // mm
wall_thickness = 3.2;   // mm (typical)
length = 250;           // mm

inner_d = outer_d - 2*wall_thickness;

difference() {
    cylinder(h = length, d = outer_d);
    translate([0,0,-0.1])
        cylinder(h = length + 0.2, d = inner_d);
}