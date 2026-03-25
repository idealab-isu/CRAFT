$fn=128;

module ht_pipe(od=125, length=1500, wall=3.2) {
    id = od - 2*wall;
    difference() {
        cylinder(h=length, d=od, center=true);
        cylinder(h=length+2, d=id, center=true);
    }
}

ht_pipe(od=125, length=1500, wall=3.2);