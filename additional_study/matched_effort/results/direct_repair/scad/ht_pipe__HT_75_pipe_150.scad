$fn = 128;

// HT 75 pipe, length 150 mm (approximate standard dimensions)
// Nominal DN 75: OD ~ 75 mm, wall ~ 2.7 mm (typical), so ID ~ 69.6 mm
// Simple straight pipe segment (no socket/bell)

pipe_length = 150;
outer_d = 75;
wall = 2.7;
inner_d = outer_d - 2*wall;

module ht_pipe(od=75, id=69.6, L=150) {
    difference() {
        cylinder(h=L, d=od);
        translate([0,0,-0.5])
            cylinder(h=L+1, d=id);
    }
}

ht_pipe(outer_d, inner_d, pipe_length);