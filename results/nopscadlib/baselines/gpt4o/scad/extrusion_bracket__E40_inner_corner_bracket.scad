module extrusion_bracket() {
    difference() {
        cube([38, 31, 8.5], center = true);
        translate([-19, -15.5, -4.25])
            cube([30, 23, 8.5], center = true);
    }
}

extrusion_bracket();