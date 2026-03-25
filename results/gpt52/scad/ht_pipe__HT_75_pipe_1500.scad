$fn=96;

module ht_pipe(od=75, length=1500, wall=2.5) {
    difference() {
        cylinder(h=length, d=od, center=true);
        cylinder(h=length+2, d=od-2*wall, center=true);
    }
}

ht_pipe(od=75, length=1500, wall=2.5);