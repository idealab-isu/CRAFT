module ht_75_cap() {
    difference() {
        // Outer cap
        cylinder(h=20, r=37.5, $fn=64);
        // Inner hollow part
        translate([0, 0, 2])
            cylinder(h=18, r=35, $fn=64);
    }
}

ht_75_cap();