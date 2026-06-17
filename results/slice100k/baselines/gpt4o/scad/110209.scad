rotate([90, 0, 0]) {
    union() {
        cylinder(h=24, r1=6, r2=6, $fn=64);
        translate([0, 0, 4]) {
            cylinder(h=4, r1=5, r2=5, $fn=64);
        }
        translate([0, 0, 8]) {
            cylinder(h=4, r1=6, r2=6, $fn=64);
        }
        translate([0, 0, 12]) {
            cylinder(h=4, r1=5, r2=5, $fn=64);
        }
        translate([0, 0, 16]) {
            cylinder(h=4, r1=6, r2=6, $fn=64);
        }
        translate([0, 0, 20]) {
            cylinder(h=4, r1=5, r2=5, $fn=64);
        }
    }
}