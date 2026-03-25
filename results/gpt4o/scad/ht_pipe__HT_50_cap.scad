module ht_50_cap() {
    difference() {
        cylinder(h=20, d=50, $fn=64);
        translate([0, 0, -1])
            cylinder(h=21, d=46, $fn=64);
    }
}

ht_50_cap();