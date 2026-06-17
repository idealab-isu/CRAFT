module ht_90_cap() {
    difference() {
        union() {
            cylinder(h=20, r1=25, r2=25, $fn=64);
            translate([0, 0, 20])
                cylinder(h=5, r1=25, r2=30, $fn=64);
            translate([0, 0, 25])
                cylinder(h=5, r1=30, r2=30, $fn=64);
        }
        translate([0, 0, -5])
            cylinder(h=30, r=20, $fn=64);
    }
}

ht_90_cap();