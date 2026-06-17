module ht_160_cap() {
    difference() {
        // Outer cap
        cylinder(h=20, d=160, $fn=64);
        // Inner hollow part
        translate([0, 0, -1])
            cylinder(h=21, d=150, $fn=64);
    }
}

translate([0, 0, 10])
    ht_160_cap();