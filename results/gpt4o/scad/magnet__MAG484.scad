module magnet() {
    difference() {
        cylinder(h=10, r=5, $fn=64);
        translate([0, 0, -1])
            cylinder(h=12, r=3, $fn=64);
    }
}

magnet();