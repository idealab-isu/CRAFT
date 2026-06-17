module component() {
    difference() {
        union() {
            translate([0, 0, 5])
                cylinder(h=10, r=5, $fn=64);
            translate([-5, -5, 0])
                cube([10, 10, 5]);
        }
        translate([0, 0, 5])
            cylinder(h=10, r=2, $fn=64);
    }
}

component();