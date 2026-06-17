difference() {
    cylinder(h=12.0, d=8.0, $fn=64);
    translate([0, 0, -1]) {
        cylinder(h=14.0, d=4.0, $fn=64);
    }
}