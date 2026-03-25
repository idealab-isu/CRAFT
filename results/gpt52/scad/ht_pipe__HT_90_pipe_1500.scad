$fn=96;

module ht_pipe(length=1500, od=90, wall=3.2) {
    difference() {
        cylinder(h=length, d=od, center=true);
        cylinder(h=length+2, d=od-2*wall, center=true);
    }
}

ht_pipe(length=1500, od=90, wall=3.2);