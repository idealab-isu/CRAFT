module ht_40_cap() {
    difference() {
        // Outer cylinder
        cylinder(h=20, d=40, $fn=64);
        // Inner cylinder (hollow part)
        translate([0, 0, 2])
            cylinder(h=18, d=36, $fn=64);
    }
}

ht_40_cap();