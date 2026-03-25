$fn=128;

module ht_pipe(od=40, wall=1.8, length=2000) {
    difference() {
        cylinder(h=length, d=od, center=true);
        cylinder(h=length+2, d=od-2*wall, center=true);
    }
}

ht_pipe(od=40, wall=1.8, length=2000);