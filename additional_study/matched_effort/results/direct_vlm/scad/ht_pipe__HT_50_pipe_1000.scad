$fn = 128;

// HT 50 pipe, length 1000 mm
// Typical HT 50 dimensions (approx.): OD 50 mm, wall 1.8 mm
// Adjust as needed.
pipe_length = 1000;
outer_d = 50;
wall = 1.8;
inner_d = outer_d - 2*wall;

module ht_pipe(len=pipe_length, od=outer_d, id=inner_d) {
    difference() {
        cylinder(h=len, d=od, center=false);
        translate([0,0,-0.1])
            cylinder(h=len+0.2, d=id, center=false);
    }
}

ht_pipe();