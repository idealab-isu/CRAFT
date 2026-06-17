$fn=128;

// HT pipe parameters (approx. for HT 50)
pipe_length = 150;          // mm
outer_diameter = 50;        // mm (nominal)
wall_thickness = 1.8;       // mm (typical for HT)
inner_diameter = outer_diameter - 2*wall_thickness;

module ht_pipe(od, id, L){
    difference(){
        cylinder(h=L, d=od);
        translate([0,0,-0.1]) cylinder(h=L+0.2, d=id);
    }
}

ht_pipe(outer_diameter, inner_diameter, pipe_length);