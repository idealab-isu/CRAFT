$fn=96;

module ht_pipe(od=50, length=150, wall=1.8) {
    difference() {
        cylinder(h=length, d=od, center=true);
        cylinder(h=length+0.2, d=od-2*wall, center=true);
    }
}

ht_pipe(od=50, length=150, wall=1.8);