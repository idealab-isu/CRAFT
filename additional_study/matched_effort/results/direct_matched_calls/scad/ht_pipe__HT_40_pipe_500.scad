$fn = 128;

// HT pipe parameters (approximate for HT 40)
pipe_length = 500;          // mm
outer_diameter = 40;        // mm (nominal)
wall_thickness = 1.8;       // mm (typical HT pipe wall)
inner_diameter = outer_diameter - 2 * wall_thickness;

module ht_pipe(od=40, id=36.4, L=500) {
    difference() {
        cylinder(h=L, d=od, center=false);
        translate([0,0,-0.5])
            cylinder(h=L+1, d=id, center=false);
    }
}

ht_pipe(outer_diameter, inner_diameter, pipe_length);