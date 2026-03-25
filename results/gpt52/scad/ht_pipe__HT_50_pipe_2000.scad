$fn=128;

module ht_pipe(od=50, length=2000, wall=1.8) {
    difference() {
        cylinder(h=length, d=od, center=true);
        cylinder(h=length+2, d=od-2*wall, center=true);
    }
}

ht_pipe(od=50, length=2000, wall=1.8);