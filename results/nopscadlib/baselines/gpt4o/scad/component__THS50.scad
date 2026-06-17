module component() {
    difference() {
        union() {
            translate([0, 0, 5])
                cylinder(h=10, r=20, $fn=64);
            translate([-15, -15, 0])
                cube([30, 30, 5]);
        }
        translate([0, 0, 5])
            cylinder(h=10, r=10, $fn=64);
    }
}

component();