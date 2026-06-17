module ht_125_cap() {
    difference() {
        // Outer cap
        cylinder(h=20, d=125, $fn=64);
        
        // Inner hollow part
        translate([0, 0, -1])
            cylinder(h=21, d=115, $fn=64);
    }
}

ht_125_cap();