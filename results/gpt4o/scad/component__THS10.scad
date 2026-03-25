module component() {
    difference() {
        union() {
            translate([0, 0, 5])
                cylinder(h=10, r=15, $fn=64);
            translate([-10, -10, 0])
                cube([20, 20, 5]);
        }
        translate([0, 0, 5])
            cylinder(h=10, r=5, $fn=64);
    }
}

component();