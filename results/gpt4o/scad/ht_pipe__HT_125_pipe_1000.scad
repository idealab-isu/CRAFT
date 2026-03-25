module ht_pipe() {
    difference() {
        cylinder(h=1000, d=125, $fn=64);
        translate([0, 0, -1])
            cylinder(h=1002, d=115, $fn=64);
    }
}

ht_pipe();