module mounting_bracket() {
    // Base plate
    difference() {
        scale([0.2, 0.1, 0.01])
            cylinder(h=1, r=0.5, $fn=64);
        translate([-0.1, -0.05, 0])
            cube([0.2, 0.1, 0.01]);
    }

    // Central rib
    translate([0, 0, 0.01])
        cube([0.02, 0.1, 0.02]);

    // Hook-shaped arm
    translate([0.01, 0, 0.03])
    rotate([0, 90, 0])
        difference() {
            scale([0.05, 0.05, 0.05])
                cylinder(h=1, r=0.5, $fn=64);
            translate([-0.5, -0.5, 0])
                cube([1, 1, 0.5]);
        }

    // Rectangular tip
    translate([0.01, 0.05, 0.08])
        cube([0.02, 0.01, 0.01]);

    // Blocky bosses/steps
    translate([-0.01, 0.02, 0.01])
        cube([0.04, 0.02, 0.02]);
    translate([-0.01, 0.06, 0.01])
        cube([0.04, 0.02, 0.02]);
}

mounting_bracket();