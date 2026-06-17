module c_shaped_clip() {
    $fn = 64;
    difference() {
        // Outer ring
        translate([0, 0, -2.5])
        rotate([90, 0, 0])
        cylinder(r=20, h=5);

        // Inner void
        translate([0, 0, -2.5])
        rotate([90, 0, 0])
        cylinder(r=15, h=5);

        // Gap
        translate([-20, -2.5, -2.5])
        cube([40, 5, 5]);

        // Bulbous end
        translate([20, 0, -2.5])
        rotate([90, 0, 0])
        cylinder(r1=5, r2=7, h=5);
    }
}

c_shaped_clip();