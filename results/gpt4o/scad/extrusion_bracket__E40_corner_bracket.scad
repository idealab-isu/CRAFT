module extrusion_bracket() {
    difference() {
        cube([40, 40, 35], center = true);
        translate([-15, -15, -35])
            cube([10, 10, 70], center = false);
        translate([5, -15, -35])
            cube([10, 10, 70], center = false);
        translate([-15, 5, -35])
            cube([10, 10, 70], center = false);
        translate([5, 5, -35])
            cube([10, 10, 70], center = false);
    }
}

extrusion_bracket();