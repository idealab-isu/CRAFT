difference() {
    cylinder(h=37.0, d=28.0, $fn=64);
    translate([0, 0, -1]) {
        cylinder(h=39.0, d=16.0, $fn=64);
    }
}