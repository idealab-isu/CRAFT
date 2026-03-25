module ht_pipe() {
    difference() {
        union() {
            cylinder(h=1000, r=50, $fn=64);
            translate([0, 0, 1000])
                rotate([0, 90, 0])
                cylinder(h=100, r=50, $fn=64);
        }
        translate([0, 0, -1])
            cylinder(h=1002, r=45, $fn=64);
    }
}

ht_pipe();