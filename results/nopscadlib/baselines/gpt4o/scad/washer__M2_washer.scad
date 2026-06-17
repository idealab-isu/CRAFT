difference() {
    cylinder(h=0.3, d=5.0, $fn=64);
    translate([0, 0, -0.1])
        cylinder(h=0.5, d=2.0, $fn=64);
}