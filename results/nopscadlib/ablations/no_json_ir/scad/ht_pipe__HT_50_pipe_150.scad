$fn = 128;

// HT 50 pipe, length 150 mm
pipe_outer_diameter = 50; // mm
pipe_wall_thickness = 2;  // mm
pipe_length = 150;        // mm

// Robust boolean overlap
eps = 0.2;

module ht_pipe(od, wall, len) {
    id = od - 2*wall;
    assert(id > 0, "Wall thickness too large for given outer diameter.");

    difference() {
        // Outer solid (not centered to avoid view/camera issues)
        cylinder(h = len, d = od, center = false);

        // Inner void: start slightly below and extend slightly above to guarantee through-cut
        translate([0, 0, -eps])
            cylinder(h = len + 2*eps, d = id, center = false);
    }
}

ht_pipe(pipe_outer_diameter, pipe_wall_thickness, pipe_length);