$fn=128;

module ht_pipe(od=50, wall=1.8, length=1500) {
    difference() {
        cylinder(h=length, d=od, center=true);
        cylinder(h=length+2, d=od-2*wall, center=true);
    }
}

ht_pipe(od=50, wall=1.8, length=1500);