module prismatic_bar() {
    // Main rectangular shaft
    translate([-0.05, -0.15, -0.05])
    cube([0.9, 0.3, 0.1]);

    // Hexagonal collar with recessed square opening
    translate([0.9, 0, 0])
    difference() {
        rotate([0, 0, 90])
        cylinder(h=0.1, r=0.075, $fn=6);
        translate([-0.025, -0.025, -0.05])
        rotate([0, 0, 45])
        cube([0.05, 0.05, 0.1]);
    }

    // Tapered/chamfered tip
    translate([-0.1, 0, 0])
    difference() {
        rotate([0, 0, 90])
        cylinder(h=0.1, r1=0.05, r2=0.025, $fn=64);
        translate([-0.05, -0.05, -0.05])
        cube([0.1, 0.1, 0.1]);
    }
}

prismatic_bar();