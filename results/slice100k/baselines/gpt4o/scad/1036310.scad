difference() {
    cylinder(h=18, d=20, $fn=64);
    translate([0, 0, -1])
        cylinder(h=20, d=10, $fn=64);
}