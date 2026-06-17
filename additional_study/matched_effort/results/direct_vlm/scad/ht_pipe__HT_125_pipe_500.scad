$fn = 128;

// HT pipe parameters (approximate, in mm)
pipe_dn = 125;          // nominal diameter
pipe_length = 500;      // length
wall_thickness = 3.2;   // typical HT DN125 wall thickness (approx.)

// Derived
outer_d = pipe_dn;
inner_d = outer_d - 2 * wall_thickness;

module ht_pipe(od, id, len) {
    difference() {
        cylinder(h = len, d = od);
        translate([0, 0, -0.5])
            cylinder(h = len + 1, d = id);
    }
}

ht_pipe(outer_d, inner_d, pipe_length);