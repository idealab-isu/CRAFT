module aluminium_extrusion() {
    difference() {
        cube([15, 15, 100], center = true);
        translate([-6.5, -6.5, -1])
            cube([2, 2, 102], center = false);
        translate([4.5, -6.5, -1])
            cube([2, 2, 102], center = false);
        translate([-6.5, 4.5, -1])
            cube([2, 2, 102], center = false);
        translate([4.5, 4.5, -1])
            cube([2, 2, 102], center = false);
    }
}

aluminium_extrusion();