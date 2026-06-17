$fn = 128;

// HT 90 pipe, length 1500 mm (simple hollow cylinder model)
pipe_length = 1500;      // mm
outer_diameter = 90;     // mm (nominal)
wall_thickness = 3.2;    // mm (typical HT wall; adjust if needed)

outer_r = outer_diameter/2;
inner_r = outer_r - wall_thickness;

module ht_pipe(len, ro, ri) {
    difference() {
        cylinder(h=len, r=ro, center=false);
        translate([0,0,-0.1]) cylinder(h=len+0.2, r=ri, center=false);
    }
}

ht_pipe(pipe_length, outer_r, inner_r);