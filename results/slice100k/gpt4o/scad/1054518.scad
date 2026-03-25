module stepped_bushing() {
    difference() {
        union() {
            // Base flange
            cylinder(h=3.0, d=10.0, $fn=64);
            // Upper boss
            translate([0, 0, 3.0])
                cylinder(h=5.0, d=6.0, $fn=64);
        }
        // Central bore
        translate([0, 0, -1.0])
            cylinder(h=10.0, d=3.0, $fn=64);
        // Side cutout on the upper boss
        translate([0, -3.0, 3.0])
            cube([6.0, 6.0, 5.0], center=false);
    }
}

translate([0, 0, -4.0])
    stepped_bushing();