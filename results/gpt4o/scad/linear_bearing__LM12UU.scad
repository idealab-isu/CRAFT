difference() {
    cylinder(h=30.0, d=21.0, $fn=64);
    translate([0, 0, -1]) // Extend slightly to ensure clean subtraction
        cylinder(h=32.0, d=12.0, $fn=64);
}