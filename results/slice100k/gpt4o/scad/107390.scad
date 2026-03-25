module c_shaped_clamp() {
    difference() {
        // Outer faceted arc
        rotate([0, 90, 0])
        rotate([0, 0, 90])
        translate([0, 0, -4.5])
        cylinder(r1=4.5, r2=4.5, h=3, $fn=12);

        // Inner concave channel
        translate([0, 0, -4.5])
        rotate([0, 90, 0])
        rotate([0, 0, 90])
        cylinder(r1=3.5, r2=3.5, h=3, $fn=64);

        // End tabs
        translate([-1.5, -0.6, -4.5])
        cube([3, 1.2, 1.5]);

        translate([-1.5, -0.6, 3])
        cube([3, 1.2, 1.5]);
    }
}

c_shaped_clamp();