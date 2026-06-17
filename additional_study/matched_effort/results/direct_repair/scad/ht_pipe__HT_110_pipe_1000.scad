$fn=128;

// HT pipe parameters (approximate for HT 110)
pipe_length = 1000;          // mm
outer_diameter = 110;        // mm
wall_thickness = 3.2;        // mm (typical for HT 110)
inner_diameter = outer_diameter - 2*wall_thickness;

module ht_pipe(od, id, len) {
    difference() {
        cylinder(h=len, d=od);
        translate([0,0,-0.5])
            cylinder(h=len+1, d=id);
    }
}

ht_pipe(outer_diameter, inner_diameter, pipe_length);