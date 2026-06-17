difference() {
    cylinder(h=0.8, d=12.0, $fn=64);
    translate([0, 0, -0.1])
        cylinder(h=1.0, d=3.0, $fn=64);
}