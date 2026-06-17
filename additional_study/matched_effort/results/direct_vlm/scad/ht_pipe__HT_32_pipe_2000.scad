$fn = 128;

// HT 32 pipe parameters (mm)
pipe_length     = 2000;
outer_diameter  = 32;
wall_thickness  = 1.8;

inner_diameter = outer_diameter - 2*wall_thickness;

// Place pipe axis along X so front/back/left/right views show the circular profile
module ht_pipe(od=32, id=28.4, L=2000) {
    difference() {
        rotate([0, 90, 0])
            cylinder(h=L, d=od, center=true);
        rotate([0, 90, 0])
            cylinder(h=L + 0.2, d=id, center=true);
    }
}

ht_pipe(outer_diameter, inner_diameter, pipe_length);