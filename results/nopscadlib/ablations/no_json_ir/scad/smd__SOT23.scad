$fn = 48;

// Target overall size (A smd): [3, 1.4, 1.0]
length = 3.0;
width  = 1.4;
height = 1.0;

// Feature sizes
terminal_height = 0.22;          // bottom metallization thickness
terminal_length = 0.55;          // end termination length along X
polarity_mark_diameter = 0.35;   // small top dimple
polarity_mark_depth = 0.08;

chamfer = 0.12;                  // corner chamfer amount
eps = 0.01;

// Chamfered body using hull of 4 corner posts (keeps it a single solid)
module chamfered_body(L, W, H, c) {
    c2 = min(c, min(L, W)/2 - 0.001);
    hull() {
        for (sx = [-1, 1])
            for (sy = [-1, 1])
                translate([sx*(L/2 - c2), sy*(W/2 - c2), 0])
                    cube([2*c2, 2*c2, H], center=true);
    }
}

// End terminations: wrap bottom + a bit up the sides, connected with overlap
module terminations(L, W, H, tL, tH) {
    side_up = min(0.35, H*0.45); // how far up the sides the metal wraps
    overlap = 0.02;

    for (sx = [-1, 1]) {
        // Bottom pad at each end
        translate([sx*(L/2 - tL/2 + overlap), 0, -H/2 + tH/2 + overlap])
            cube([tL + 2*overlap, W + 2*overlap, tH + 2*overlap], center=true);

        // Side wrap (vertical band) at each end
        translate([sx*(L/2 - tL/2 + overlap), 0, -H/2 + side_up/2])
            cube([tL + 2*overlap, W + 2*overlap, side_up], center=true);
    }
}

// Polarity mark as a shallow dimple on top (subtracted), stays within body
module polarity_dimple(L, W, H, d, depth) {
    translate([-L/4, 0, H/2 - depth/2])
        cylinder(h=depth + eps, d=d, center=true);
}

module smd_component() {
    union() {
        // Main body with chamfered corners and a polarity dimple
        difference() {
            chamfered_body(length, width, height, chamfer);
            polarity_dimple(length, width, height, polarity_mark_diameter, polarity_mark_depth);
        }

        // Terminations (connected to body with slight overlap)
        terminations(length, width, height, terminal_length, terminal_height);
    }
}

smd_component();