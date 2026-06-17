difference() {
    cylinder(h=1.0, d=10.0, $fn=64);
    translate([0, 0, -0.5])
        cylinder(h=2.0, d=5.0, $fn=64);
}