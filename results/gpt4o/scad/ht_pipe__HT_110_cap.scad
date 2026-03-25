module ht_110_cap() {
    difference() {
        // Outer cap
        cylinder(h=20, d=110, $fn=64);
        // Inner hollow part
        translate([0, 0, -1])
            cylinder(h=21, d=104, $fn=64);
    }
}

ht_110_cap();