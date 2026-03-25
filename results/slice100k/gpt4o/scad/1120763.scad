module link_plate() {
    difference() {
        // Main body of the plate
        union() {
            // Central rectangular part
            cube([46.6, 7.0, 2.5], center=true);
            // Rounded ends
            translate([-23.3, 0, 0])
                cylinder(h=2.5, r=3.5, $fn=64);
            translate([23.3, 0, 0])
                cylinder(h=2.5, r=3.5, $fn=64);
        }
        // Large through-holes
        translate([-23.3, 0, 0])
            cylinder(h=3, r=2.5, $fn=64);
        translate([23.3, 0, 0])
            cylinder(h=3, r=2.5, $fn=64);
        // Small through-holes pattern (left side)
        translate([-28.3, 2.0, 0])
            cylinder(h=3, r=0.75, $fn=64);
        translate([-26.3, -2.0, 0])
            cylinder(h=3, r=0.75, $fn=64);
        translate([-24.3, 2.0, 0])
            cylinder(h=3, r=0.75, $fn=64);
        // Small through-holes pattern (right side, mirrored)
        translate([28.3, -2.0, 0])
            cylinder(h=3, r=0.75, $fn=64);
        translate([26.3, 2.0, 0])
            cylinder(h=3, r=0.75, $fn=64);
        translate([24.3, -2.0, 0])
            cylinder(h=3, r=0.75, $fn=64);
    }
}

link_plate();