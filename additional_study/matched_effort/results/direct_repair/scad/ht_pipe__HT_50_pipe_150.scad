$fn = 128;

// HT pipe parameters (approximate for HT 50)
pipe_length = 150;          // mm
outer_diameter = 50;        // mm (nominal)
wall_thickness = 1.8;       // mm (typical HT)
inner_diameter = outer_diameter - 2*wall_thickness;

module ht_pipe(od=50, id=46.4, L=150) {
    difference() {
        cylinder(h=L, d=od);
        translate([0,0,-0.5])
            cylinder(h=L+1, d=id);
    }
}

ht_pipe(outer_diameter, inner_diameter, pipe_length);