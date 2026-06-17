$fn=96;

module ht_pipe(od=75, length=250, wall=2.7) {
    difference() {
        cylinder(h=length, d=od, center=true);
        cylinder(h=length+2, d=od-2*wall, center=true);
    }
}

ht_pipe(od=75, length=250, wall=2.7);