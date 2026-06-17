module ht32_cap() {
    difference() {
        // Outer cap
        cylinder(h=10, r1=16, r2=16, $fn=64);
        // Inner hollow part
        translate([0, 0, -1])
            cylinder(h=11, r1=14, r2=14, $fn=64);
    }
}

ht32_cap();