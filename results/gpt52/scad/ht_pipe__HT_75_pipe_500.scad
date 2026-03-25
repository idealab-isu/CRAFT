$fn=128;

module ht_pipe(od=75, length=500, wall=2.7) {
    difference() {
        cylinder(h=length, d=od, center=true);
        cylinder(h=length+2, d=od-2*wall, center=true);
    }
}

ht_pipe(od=75, length=500, wall=2.7);