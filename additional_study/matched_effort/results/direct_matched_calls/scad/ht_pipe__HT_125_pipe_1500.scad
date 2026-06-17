$fn = 128;

// HT pipe parameters (mm)
pipe_dn = 125;          // nominal diameter
pipe_length = 1500;     // length

// Assumptions for a typical HT (PP) DN125 pipe:
// - Outer diameter ~ 125 mm
// - Wall thickness ~ 3.2 mm (common for DN125 HT pipes)
od = 125;
wall = 3.2;
id = od - 2*wall;

module ht_pipe(od, id, length) {
    difference() {
        cylinder(h = length, d = od, center = false);
        translate([0,0,-0.5])
            cylinder(h = length + 1, d = id, center = false);
    }
}

ht_pipe(od, id, pipe_length);