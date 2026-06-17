$fn=128;

module ht_pipe(od=125, length=250, wall=3.2) {
    difference() {
        cylinder(h=length, d=od, center=true);
        cylinder(h=length+2, d=od-2*wall, center=true);
    }
}

ht_pipe(od=125, length=250, wall=3.2);