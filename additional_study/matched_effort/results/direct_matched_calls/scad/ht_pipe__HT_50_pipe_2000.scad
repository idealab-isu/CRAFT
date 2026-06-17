$fn = 128;

// HT 50 pipe (approx): DN 50, length 2000 mm
// Typical HT (PP) dimensions vary by manufacturer; using common approximations:
// Outer diameter ~ 50 mm, wall thickness ~ 1.8 mm.
pipe_length = 2000;
outer_d = 50;
wall = 1.8;
inner_d = outer_d - 2*wall;

module ht_pipe(len=pipe_length, od=outer_d, id=inner_d) {
    difference() {
        cylinder(h=len, d=od, center=false);
        translate([0,0,-0.5])
            cylinder(h=len+1, d=id, center=false);
    }
}

ht_pipe();