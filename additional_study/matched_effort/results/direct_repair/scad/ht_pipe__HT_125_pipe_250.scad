$fn = 180;

// HT pipe parameters (approximate, adjustable)
pipe_dn = 125;          // nominal diameter (mm)
pipe_length = 250;      // length (mm)
wall_thickness = 3.2;   // typical HT wall thickness (mm), adjust if needed

// Derived
outer_d = pipe_dn;
inner_d = outer_d - 2*wall_thickness;

module ht_pipe(od, id, L) {
    difference() {
        cylinder(h = L, d = od, center = false);
        translate([0,0,-0.1])
            cylinder(h = L + 0.2, d = id, center = false);
    }
}

ht_pipe(outer_d, inner_d, pipe_length);