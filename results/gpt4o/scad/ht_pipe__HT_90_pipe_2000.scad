module ht_pipe() {
    difference() {
        union() {
            cylinder(h=2000, r=100, $fn=64);
            translate([0, 0, 2000])
                rotate([90, 0, 0])
                cylinder(h=200, r=100, $fn=64);
        }
        translate([0, 0, -1])
            cylinder(h=2002, r=90, $fn=64);
    }
}

ht_pipe();