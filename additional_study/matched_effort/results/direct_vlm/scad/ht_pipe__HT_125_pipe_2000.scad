$fn = 128;

// HT 125 pipe parameters (mm)
outer_diameter = 125;
wall_thickness = 3.2;
length = 2000;

inner_diameter = outer_diameter - 2*wall_thickness;

module ht_pipe(od, id, L) {
    eps = 0.5; // small overlap to ensure clean boolean

    // Orient along X so all orthographic views show the full length consistently
    rotate([0, 90, 0])
    difference() {
        cylinder(h = L, d = od, center = true);
        cylinder(h = L + 2*eps, d = id, center = true);
    }
}

ht_pipe(outer_diameter, inner_diameter, length);