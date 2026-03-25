module aluminium_extrusion() {
    difference() {
        cube([30, 30, 100], center = true);
        translate([-12.5, -12.5, -50])
            cube([5, 5, 100]);
        translate([7.5, -12.5, -50])
            cube([5, 5, 100]);
        translate([-12.5, 7.5, -50])
            cube([5, 5, 100]);
        translate([7.5, 7.5, -50])
            cube([5, 5, 100]);
    }
}

aluminium_extrusion();