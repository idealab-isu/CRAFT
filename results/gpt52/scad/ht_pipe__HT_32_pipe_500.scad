$fn=96;

pipe_length = 500;
od = 32;
wall = 1.8;
id = od - 2*wall;

module ht_pipe(len, outer_d, inner_d){
    difference(){
        cylinder(h=len, d=outer_d, center=true);
        cylinder(h=len+2, d=inner_d, center=true);
    }
}

ht_pipe(pipe_length, od, id);