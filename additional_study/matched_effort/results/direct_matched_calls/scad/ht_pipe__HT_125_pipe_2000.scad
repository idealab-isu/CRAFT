$fn = 128;

// HT pipe parameters (mm)
pipe_dn = 125;          // nominal diameter
pipe_length = 2000;     // length
wall_thickness = 3.2;   // typical HT wall thickness (approx.)

// Derived
outer_d = pipe_dn;
inner_d = max(outer_d - 2*wall_thickness, 0.1);

module ht_pipe(od, id, L) {
    difference() {
        cylinder(h = L, d = od, center = false);
        translate([0,0,-0.5])
            cylinder(h = L + 1, d = id, center = false);
    }
}

ht_pipe(outer_d, inner_d, pipe_length);