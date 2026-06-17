$fn = 128;

// HT pipe (approx.) - DN40, length 250 mm
// Typical HT DN40 dimensions (approx):
// - Outer diameter: 40 mm
// - Wall thickness: 1.8 mm
// Adjust as needed.

pipe_length = 250;
outer_d = 40;
wall = 1.8;

inner_d = outer_d - 2*wall;

difference() {
    cylinder(h = pipe_length, d = outer_d);
    translate([0,0,-0.1])
        cylinder(h = pipe_length + 0.2, d = inner_d);
}