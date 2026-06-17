$fn=96;

module ht_pipe(od=32, wall=1.8, length=250) {
    difference() {
        translate([0,0,-length/2])
            cylinder(h=length, d=od);
        translate([0,0,-length/2-0.1])
            cylinder(h=length+0.2, d=od-2*wall);
    }
}

ht_pipe(od=32, wall=1.8, length=250);