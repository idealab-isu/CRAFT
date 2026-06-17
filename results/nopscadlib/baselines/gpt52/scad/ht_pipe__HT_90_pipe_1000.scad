$fn=96;

pipe_length = 1000;
outer_d = 90;
wall = 3.2;
inner_d = outer_d - 2*wall;

module ht_pipe(len, od, id){
    difference(){
        cylinder(h=len, d=od, center=true);
        cylinder(h=len+2, d=id, center=true);
    }
}

ht_pipe(pipe_length, outer_d, inner_d);